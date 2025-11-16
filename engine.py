import pandas as pd
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
from collections import defaultdict
from datetime import datetime, timedelta
from typing import List, Dict, Tuple

class ProductRecommendationEngine:

    
    def __init__(self):
        self.user_item_matrix = None
        self.item_similarity_matrix = None
        self.user_similarity_matrix = None
        self.product_features = None
        self.orders_df = None
        self.products_df = None
        
    def prepare_data(self, orders_df: pd.DataFrame, products_df: pd.DataFrame):
        self.orders_df = orders_df.copy()
        self.products_df = products_df.copy()
        
        self.orders_df['order_date'] = pd.to_datetime(self.orders_df['order_date'])

        if 'price' in self.products_df.columns:
            self.products_df['price'] = self.products_df['price'].astype(float)
        
        self.user_item_matrix = self.orders_df.groupby(['user_id', 'product_id'])['quantity'].sum().unstack(fill_value=0)
        
        print(f"Data prepared: {len(self.orders_df)} orders, {self.user_item_matrix.shape[0]} users, {self.user_item_matrix.shape[1]} products")
    
    def build_collaborative_filtering(self):
        normalized_matrix = self.user_item_matrix.div(self.user_item_matrix.sum(axis=1), axis=0).fillna(0)
        self.item_similarity_matrix = cosine_similarity(normalized_matrix.T)
        self.item_similarity_matrix = pd.DataFrame(
            self.item_similarity_matrix,
            index=self.user_item_matrix.columns,
            columns=self.user_item_matrix.columns
        )
        
        self.user_similarity_matrix = cosine_similarity(self.user_item_matrix)
        self.user_similarity_matrix = pd.DataFrame(
            self.user_similarity_matrix,
            index=self.user_item_matrix.index,
            columns=self.user_item_matrix.index
        )
        
        print("Collaborative filtering models built")
    
    def build_content_based_features(self):
        features_list = []
        
        category_dummies = pd.get_dummies(self.products_df['category'], prefix='cat')
        
        brand_dummies = pd.get_dummies(self.products_df['brand'], prefix='brand')
        
        price_bins = pd.qcut(self.products_df['price'], q=3, labels=['low', 'medium', 'high'], duplicates='drop')
        price_dummies = pd.get_dummies(price_bins, prefix='price')
        
        self.product_features = pd.concat([
            self.products_df[['product_id']],
            category_dummies,
            brand_dummies,
            price_dummies
        ], axis=1)
        
        self.product_features.set_index('product_id', inplace=True)
        
        print(f"Content-based features built: {self.product_features.shape[1]} features per product")
    
    def get_collaborative_recommendations(self, user_id: int, n_recommendations: int = 10) -> List[Tuple[int, float]]:
        if user_id not in self.user_item_matrix.index:
            return []
        
        user_purchases = self.user_item_matrix.loc[user_id]
        purchased_items = user_purchases[user_purchases > 0].index.tolist()
        
        item_scores = defaultdict(float)
        for item in purchased_items:
            if item in self.item_similarity_matrix.index:
                similar_items = self.item_similarity_matrix[item].sort_values(ascending=False)[1:n_recommendations+1]
                for similar_item, score in similar_items.items():
                    if similar_item not in purchased_items:
                        item_scores[similar_item] += score * user_purchases[item]
        
        if user_id in self.user_similarity_matrix.index:
            similar_users = self.user_similarity_matrix[user_id].sort_values(ascending=False)[1:11]
            for similar_user_id, similarity_score in similar_users.items():
                similar_user_purchases = self.user_item_matrix.loc[similar_user_id]
                for item, purchase_count in similar_user_purchases[similar_user_purchases > 0].items():
                    if item not in purchased_items:
                        item_scores[item] += similarity_score * purchase_count
        
        recommendations = sorted(item_scores.items(), key=lambda x: x[1], reverse=True)[:n_recommendations]
        return recommendations
    
    def get_content_based_recommendations(self, user_id: int, n_recommendations: int = 10) -> List[Tuple[int, float]]:
        if user_id not in self.user_item_matrix.index:
            return []
        
        user_purchases = self.user_item_matrix.loc[user_id]
        purchased_items = user_purchases[user_purchases > 0].index.tolist()
        
        purchased_items = [item for item in purchased_items if item in self.product_features.index]
        
        if not purchased_items:
            return []
        
        user_profile = np.zeros(self.product_features.shape[1])
        total_weight = 0
        for item in purchased_items:
            weight = user_purchases[item]
            user_profile += self.product_features.loc[item].values * weight
            total_weight += weight
        user_profile /= total_weight
        
        all_products = self.product_features.index.tolist()
        similarities = {}
        for product in all_products:
            if product not in purchased_items:
                product_features = self.product_features.loc[product].values
                similarity = cosine_similarity([user_profile], [product_features])[0][0]
                similarities[product] = similarity
        
        recommendations = sorted(similarities.items(), key=lambda x: x[1], reverse=True)[:n_recommendations]
        return recommendations
    
    def get_trending_recommendations(self, user_id: int = None, n_recommendations: int = 10, days: int = 30) -> List[Tuple[int, float]]:
        cutoff_date = datetime.now() - timedelta(days=days)
        recent_orders = self.orders_df[self.orders_df['order_date'] >= cutoff_date]
        
        purchased_items = []
        if user_id and user_id in self.user_item_matrix.index:
            user_purchases = self.user_item_matrix.loc[user_id]
            purchased_items = user_purchases[user_purchases > 0].index.tolist()
            
            user_products = self.products_df[self.products_df['product_id'].isin(purchased_items)]
            preferred_categories = user_products['category'].value_counts().head(3).index.tolist()
            
            category_products = self.products_df[self.products_df['category'].isin(preferred_categories)]['product_id'].tolist()
            recent_orders = recent_orders[recent_orders['product_id'].isin(category_products)]
        
        trending_scores = recent_orders.groupby('product_id')['quantity'].sum()
        
        trending_scores = trending_scores[~trending_scores.index.isin(purchased_items)]
        
        recommendations = trending_scores.sort_values(ascending=False).head(n_recommendations)
        return [(product_id, score) for product_id, score in recommendations.items()]
    
    def get_hybrid_recommendations(self, user_id: int, n_recommendations: int = 10) -> List[Dict]:
        collab_recs = self.get_collaborative_recommendations(user_id, n_recommendations * 2)
        content_recs = self.get_content_based_recommendations(user_id, n_recommendations * 2)
        trending_recs = self.get_trending_recommendations(user_id, n_recommendations * 2)
        
        combined_scores = defaultdict(lambda: {'score': 0, 'sources': []})
        
        for product_id, score in collab_recs:
            combined_scores[product_id]['score'] += score * 0.4
            combined_scores[product_id]['sources'].append('collaborative')
        
        for product_id, score in content_recs:
            combined_scores[product_id]['score'] += score * 0.3
            combined_scores[product_id]['sources'].append('content')
        
        max_trending = max([score for _, score in trending_recs]) if trending_recs else 1
        for product_id, score in trending_recs:
            normalized_score = score / max_trending
            combined_scores[product_id]['score'] += normalized_score * 0.3
            combined_scores[product_id]['sources'].append('trending')
        
        sorted_recommendations = sorted(
            combined_scores.items(),
            key=lambda x: x[1]['score'],
            reverse=True
        )[:n_recommendations]
        
        recommendations = []
        for product_id, data in sorted_recommendations:
            product_info = self.products_df[self.products_df['product_id'] == product_id].iloc[0]
            recommendations.append({
                'product_id': product_id,
                'score': data['score'],
                'sources': data['sources'],
                'category': product_info['category'],
                'price': product_info['price'],
                'brand': product_info['brand']
            })
        
        return recommendations
    
    def train(self):
        print("Training recommendation engine...")
        self.build_collaborative_filtering()
        self.build_content_based_features()
        print("Training complete!")
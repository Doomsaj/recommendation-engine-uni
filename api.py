from flask import Flask, jsonify, request
import pickle

app = Flask(__name__)

print("Loading recommendation model...")
with open('recommendation_model.pkl', 'rb') as f:
    recommendation_engine = pickle.load(f)
print("✅ Model ready!")

@app.route('/recommendations/<int:user_id>')
def get_recommendations(user_id):
    n = request.args.get('limit', default=10, type=int)
    
    recommendations = recommendation_engine.get_hybrid_recommendations(
        user_id=user_id,
        n_recommendations=n
    )
    
    return jsonify({
        'user_id': user_id,
        'recommendations': recommendations
    })

@app.route('/trending')
def get_trending():
    days = request.args.get('days', default=30, type=int)
    limit = request.args.get('limit', default=10, type=int)
    
    trending = recommendation_engine.get_trending_recommendations(
        n_recommendations=limit,
        days=days
    )
    
    return jsonify({'trending': trending})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5050)
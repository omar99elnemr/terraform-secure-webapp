# backend-app/app.py - Flask backend application

from flask import Flask, jsonify, request
import socket
import os
import datetime
import json

app = Flask(__name__)

def get_instance_info():
    """Get instance information"""
    hostname = socket.gethostname()
    try:
        local_ip = socket.gethostbyname(hostname)
    except:
        local_ip = "unknown"
    
    return {
        "hostname": hostname,
        "local_ip": local_ip,
        "timestamp": datetime.datetime.now().isoformat()
    }

@app.route('/')
def home():
    """Main endpoint"""
    instance_info = get_instance_info()
    
    response_data = {
        "message": "Hello from Secure Web App Backend!",
        "status": "success",
        "server_info": instance_info,
        "request_info": {
            "remote_addr": request.remote_addr,
            "user_agent": request.headers.get('User-Agent'),
            "method": request.method,
            "path": request.path,
            "headers": dict(request.headers)
        }
    }
    
    return jsonify(response_data)

@app.route('/health')
def health_check():
    """Health check endpoint for ALB"""
    return jsonify({
        "status": "healthy",
        "timestamp": datetime.datetime.now().isoformat(),
        "server": get_instance_info()["hostname"]
    })

@app.route('/api/status')
def status():
    """Detailed status endpoint"""
    instance_info = get_instance_info()
    
    return jsonify({
        "application": "Secure Web App Backend",
        "version": "1.0.0",
        "status": "running",
        "server": instance_info,
        "environment": {
            "python_version": os.sys.version,
            "flask_env": os.environ.get('FLASK_ENV', 'production')
        }
    })

@app.route('/api/test')
def test():
    """Test endpoint for load balancing verification"""
    instance_info = get_instance_info()
    
    return jsonify({
        "test": "successful",
        "message": f"Response from server {instance_info['hostname']}",
        "server_details": instance_info
    })

@app.errorhandler(404)
def not_found(error):
    """404 error handler"""
    return jsonify({
        "error": "Not Found",
        "message": "The requested resource was not found",
        "status_code": 404,
        "server": get_instance_info()["hostname"]
    }), 404

@app.errorhandler(500)
def internal_error(error):
    """500 error handler"""
    return jsonify({
        "error": "Internal Server Error",
        "message": "An internal server error occurred",
        "status_code": 500,
        "server": get_instance_info()["hostname"]
    }), 500

if __name__ == '__main__':
    print(f"Starting Flask application on {get_instance_info()['hostname']}")
    print(f"Health check available at: /health")
    print(f"Main endpoint available at: /")
    
    # Run on all interfaces, port 5000
    app.run(host='0.0.0.0', port=5000, debug=False)
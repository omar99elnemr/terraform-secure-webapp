# backend-app/app.py - Flask backend application

from flask import Flask, jsonify, request, render_template_string
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
    """Main endpoint - clear, neat, and appealing homepage with improved color scheme and readability"""
    instance_info = get_instance_info()
    html = '''
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Omar's Secure Web App - ITI Terraform Final Task</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <style>
            body { background: #f8fafc; color: #222; min-height: 100vh; }
            .card {
                background: #fff;
                border: 1px solid #e3e6ea;
                border-radius: 1rem;
                box-shadow: 0 4px 24px rgba(0,0,0,0.07);
                margin-top: 2rem;
            }
            .display-4 { font-weight: 700; letter-spacing: -1px; color: #1e3c72; }
            .highlight { color: #0d6efd; font-weight: bold; }
            .footer { margin-top: 2rem; color: #888; font-size: 0.97rem; }
            .instance-info { font-size: 1.1rem; margin-top: 1.5rem; color: #333; }
            .project-note { font-size: 1.15rem; margin-top: 1.5rem; color: #0d6efd; }
            .lead { color: #444; }
        </style>
    </head>
    <body>
        <div class="container py-5">
            <div class="row justify-content-center">
                <div class="col-md-8">
                    <div class="card p-4 text-center">
                        <h1 class="display-4 mb-3">It's working! 🎉</h1>
                        <p class="lead">Refresh to see the <span class="highlight">instance</span> info change.<br>This project was implemented by <span class="highlight">Omar ElNemr</span> as a final task of the ITI's Terraform on AWS course.</p>
                        <div class="instance-info mt-4">
                            <div><b>Server Hostname:</b> <span class="highlight">{{ hostname }}</span></div>
                            <div><b>Server IP:</b> <span class="highlight">{{ local_ip }}</span></div>
                            <div><b>Timestamp:</b> {{ timestamp }}</div>
                        </div>
                    </div>
                    <div class="footer text-center">&copy; 2025 Omar's Secure Web App | Powered by Flask &amp; AWS using Terraform</div>
                </div>
            </div>
        </div>
    </body>
    </html>
    '''
    return render_template_string(html,
        hostname=instance_info["hostname"],
        local_ip=instance_info["local_ip"],
        timestamp=instance_info["timestamp"]
    )

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
    """Test endpoint for load balancing verification - returns instance info and Omar's name"""
    instance_info = get_instance_info()
    return jsonify({
        "test": "successful",
        "message": f"Hello Omar! Response from server {instance_info['hostname']}",
        "server_details": instance_info,
        "owner": "Omar"
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
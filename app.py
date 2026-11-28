from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import socket
import time

APP_VERSION = "2.1.0"

class StatusHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path in ("/", "/health"):
            payload = {
                "service": "ops-status-api",
                "version": APP_VERSION,
                "status": "healthy",
                "hostname": socket.gethostname(),
            }
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write((json.dumps(payload) + "\n").encode("utf-8"))
        elif self.path == "/slow":
            time.sleep(5)
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(b'{"status": "slow-ok"}\n')
        else:
            self.send_response(404)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(b'{"error": "not found"}\n')

if __name__ == "__main__":
    print(f"Starting ops-status-api v{APP_VERSION} on 0.0.0.0:8000")
    HTTPServer(("0.0.0.0", 8000), StatusHandler).serve_forever()

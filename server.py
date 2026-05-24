import http.server
import socketserver

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        # Эти заголовки обязательны для работы pthreads в WebAssembly
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        super().end_headers()

PORT = 8080
with socketserver.TCPServer(("", PORT), MyHTTPRequestHandler) as httpd:
    print(f"Сервер запущен на http://localhost:{PORT}")
    print("Используйте этот адрес для открытия приложения в Chrome")
    httpd.serve_forever()

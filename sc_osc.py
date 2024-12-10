from pythonosc.udp_client import SimpleUDPClient

class SuperColliderClient:
    def __init__(self, ip="127.0.0.1", port=57120):
        """
        SuperCollider와 OSC 통신을 설정합니다.
        Args:
            ip (str): SuperCollider가 실행 중인 호스트 IP (기본값: 로컬호스트)
            port (int): SuperCollider가 수신 대기 중인 포트 (기본값: 57120)
        """
        self.client = SimpleUDPClient(ip, port)

    def send_message(self, label, confidence):
        """
        탐지 결과를 SuperCollider로 전송합니다.
        
        Args:
            label (str): 탐지된 클래스 이름 (예: "fist", "one" 등)
            confidence (float): 탐지 신뢰도 (0.0 ~ 1.0)
        """
        try:
            self.client.send_message("/from_python", [label, confidence])
            print(f"Sent OSC message: {label}, {confidence}")
        except Exception as e:
            print(f"Error sending OSC message: {e}")

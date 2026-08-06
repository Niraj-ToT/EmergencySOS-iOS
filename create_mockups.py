from pathlib import Path
import struct
import zlib

root = Path('Design/Screenshots')
root.mkdir(parents=True, exist_ok=True)
files = [
    ('01_Splash.png', 'Splash'),
    ('02_Login.png', 'Login'),
    ('03_Register.png', 'Register'),
    ('04_ForgotPassword.png', 'Forgot Password'),
    ('05_Home.png', 'Home'),
    ('06_Contacts.png', 'Contacts'),
    ('07_Profile.png', 'Profile'),
]


def write_png(path: Path, width: int, height: int, color: tuple[int, int, int, int]):
    def chunk(tag: bytes, data: bytes) -> bytes:
        return struct.pack('!I', len(data)) + tag + data + struct.pack('!I', 0xFFFFFFFF & (sum(tag) + sum(data)))

    raw = bytearray()
    for y in range(height):
        raw.append(0)
        for x in range(width):
            if 60 <= x <= 1020 and 80 <= y <= 1840:
                bg = (30, 41, 59, 255)
            elif 90 <= x <= 990 and 120 <= y <= 300:
                bg = (54, 117, 181, 255)
            else:
                bg = color
            raw.extend(bg[:3])

    with path.open('wb') as f:
        f.write(b'\x89PNG\r\n\x1a\n')
        f.write(chunk(b'IHDR', struct.pack('!IIBBBBB', width, height, 8, 2, 0, 0, 0)))
        f.write(chunk(b'IDAT', zlib.compress(bytes(raw), 9)))
        f.write(chunk(b'IEND', b''))


for name, _ in files:
    write_png(root / name, 1080, 1920, (18, 32, 46, 255))

print(f'created {len(files)} mockup images')

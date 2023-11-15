import secrets
import string


def random_string(length: int = 32):
    return "".join(secrets.choice(string.ascii_letters) for _ in range(length))

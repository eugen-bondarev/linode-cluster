import os
import base64

def exec(cmd: str):
  os.system(cmd)

def ensure_dir_exists(dir: str):
  if os.path.exists(dir):
    return
  os.mkdir(dir, 0o777)

def prepare_dir_for_file(file_path: str):
  parent_dir = os.path.dirname(file_path)
  ensure_dir_exists(parent_dir)

def read_file(file_path: str):
  return open(file_path).read()

def write_to_file(file_path: str, content: str):
  handle = open(file_path, 'w')
  handle.write(content)
  handle.close()

def base64_decode_file_in_place(file_path: str):
  encoded_content = read_file(file_path)
  decoded_content = base64.b64decode(encoded_content).decode()
  write_to_file(file_path, decoded_content)

def download_kubeconfig(dst: str):
  exec('terraform -chdir="cloud" output -raw kubeconfig > {0}'.format(dst))  

# Script
kubeconfig_path = './cluster/secrets/kubeconfig'
prepare_dir_for_file(kubeconfig_path)
download_kubeconfig(kubeconfig_path)
base64_decode_file_in_place(kubeconfig_path)
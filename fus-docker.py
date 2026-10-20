#!/usr/bin/env python3

import subprocess
import sys
import configparser
from pathlib import Path

script_dir = Path(__file__).resolve().parent
config_file=f"{script_dir}/.docker.ini"

class cmd_runner:
    def __init__(self, config):
        self.docker_path = script_dir
        self.docker_tag = config.get("docker-fus", "tag")
        self.docker_script = "docker_run.sh"
        self.build_dir = config.get("docker-fus", "build_dir")

    def run(self, cmd):
        subprocess.run( ["bash", f"{self.docker_path}/{self.docker_script}", "-i" ,self.docker_tag, "-d", self.build_dir, "-c", cmd], check=True)

if __name__ == "__main__":

    if len(sys.argv) < 2:
        print("Usage: fus-docker.py <config_file> <command>")
        sys.exit(1)

    command = sys.argv[1]

    config = configparser.ConfigParser()
    config.read(config_file)

    runner = cmd_runner(config)
    runner.run(command)
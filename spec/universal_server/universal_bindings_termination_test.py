import sys
from subprocess import Popen, PIPE
from time import sleep

import psutil
import pytest


@pytest.mark.parametrize("reason", ["normal", "crash"])
def test_automatic_eyes_universal_termination_on_ruby_termination(reason):
    ruby_process = Popen(["ruby", "spec/universal_server/single-server-sdk.rb"], stdin=PIPE, stdout=PIPE)
    output_line = ruby_process.stdout.readline()
    assert output_line.startswith(b"SDKServer")
    (eyes_universal,) = psutil.Process(ruby_process.pid).children()
    assert eyes_universal.is_running()
    termination_type = b"1\n" if reason == "normal" else b"2\n"
    ruby_process.stdin.write(termination_type)
    ruby_process.stdin.flush()
    ruby_process.wait()
    sleep(1)  # eyes-universal receives EOF on stdin and terminates, might take time

    assert not eyes_universal.is_running()


@pytest.mark.parametrize("reason", ["normal", "crash"])
def test_parallel_eyes_universal_termination_on_ruby_termination(reason):
    processes = []
    for _ in range(2):
        ruby_process = Popen(["ruby", "spec/universal_server/single-server-sdk.rb"], stdin=PIPE, stdout=PIPE)
        output_line = ruby_process.stdout.readline()
        assert output_line.startswith(b"SDKServer")
        (eyes_universal,) = psutil.Process(ruby_process.pid).children()
        assert eyes_universal.is_running()
        processes.append((ruby_process, eyes_universal))

    for ruby_process, eyes_universal in processes:
        termination_type = b"1\n" if reason == "normal" else b"2\n"
        ruby_process.stdin.write(termination_type)
        ruby_process.stdin.flush()
        ruby_process.wait()
        sleep(1)  # eyes-universal receives EOF on stdin and terminates, might take time
        assert not eyes_universal.is_running()
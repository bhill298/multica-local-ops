"""Offline check. Run in a disposable worker with fresh project mount fixtures."""
from pathlib import Path
import subprocess
import tempfile

from docx import Document
from selenium import webdriver
from selenium.webdriver.chrome.service import Service


def run(*args):
    return subprocess.check_output(args, text=True)


assert Path("/project/input/canary").read_text().strip() == "fixture"
assert subprocess.run(["sudo", "touch", "/project/input/root-write"]).returncode != 0
Path("/project/exchange/proof.txt").write_text("worker wrote this\n")
assert "ELF Header" in run("readelf", "-h", "/usr/bin/true")
assert run("xvfb-run", "-a", "xdotool", "getdisplaygeometry").strip()

with tempfile.TemporaryDirectory() as base:
    folder = Path(base)
    document = Document()
    document.add_paragraph("Document proof")
    document.save(folder / "proof.docx")
    run("libreoffice", "--headless", "--convert-to", "pdf", "--outdir",
        base, str(folder / "proof.docx"))
    assert "Document proof" in run("pdftotext", str(folder / "proof.pdf"), "-")

options = webdriver.ChromeOptions()
options.add_argument("--headless")
with webdriver.Chrome(service=Service("/usr/bin/chromedriver"), options=options) as browser:
    browser.get("data:text/html,<button onclick='document.title=42'>Go</button>")
    browser.find_element("tag name", "button").click()
    assert browser.title == "42" and browser.get_screenshot_as_png().startswith(b"\x89PNG")
print("Mounts, binary inspection, X display, document rendering and browser passed.")

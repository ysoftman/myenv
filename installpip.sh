#!/bin/bash
# uv(extremely fast Python package and project manager)
# https://github.com/astral-sh/uv
PIP="pip"
if command -v uv >/dev/null 2>&1; then
    PIP="uv pip"
    additional_for_uv_pip_option="--system"
fi
${PIP} install --upgrade pip ${additional_for_uv_pip_option}
${PIP} install aiofiles annotated-types ansi2html ansible ansible-core anyio asitop azure-ai-translation-text azure-core blessed bottle brotli certifi cffi charset-normalizer click coloredlogs cryptography cssselect2 dashing dataclass-wizard deepl distro duckdb fastapi ffmpy filelock flatbuffers fonttools fsspec gradio gradio-client gradio-pdf greenlet h11 harlequin harlequin-mysql html5lib httpcore httpx huggingface-hub humanfriendly idna isodate jinja2 jiter jmespath libtmux linkify-it-py markdown-it-py markupsafe mdit-py-plugins mdurl mpmath msgpack mysql-connector-python netaddr numpy ollama onnx onnxruntime openai opencv-python-headless orjson packaging pandas pbr pdf2zh pdfminer-six pillow pip platformdirs pokemon-terminal presenterm-export prompt-toolkit protobuf psutil pyarrow pycparser pydantic pydantic-core pydub pydyf pygame pygments pymupdf pynvim pyperclip pyphen python-dateutil python-multipart pytimeparse2 pytz pyyaml questionary requests resolvelib rich rich-click ruamel-yaml ruamel-yaml-clib ruff safehttpx semantic-version setuptools shandy-sqlfmt shellingham simplejson six sniffio sqlite3-to-mysql starlette sympy tabulate tenacity tencentcloud-sdk-python textual textual-fastdatatable textual-textarea tinycss2 tomlkit tqdm tree-sitter tree-sitter-languages typer typing-extensions tzdata uc-micro-py unidecode unimatrix urllib3 uv uvicorn wcwidth weasyprint webencodings websockets zopfli  ${additional_for_uv_pip_option}

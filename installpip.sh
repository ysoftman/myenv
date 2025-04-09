#!/bin/bash
# pip 가 없을때 설치
# python -m ensurepip --upgrade
# python -m pip install --upgrade pip
PIP="pip"
# uv(extremely fast Python package and project manager)
# https://github.com/astral-sh/uv
if command -v uv >/dev/null 2>&1; then
    PIP="uv pip"
    additional_for_uv_pip_option="--system"
fi
${PIP} install --upgrade pip ${additional_for_uv_pip_option}
${PIP} install aiofiles annotated-types ansi2html ansible ansible-core anyio asitop azure-ai-translation-text azure-core babeldoc bitarray bitstring blessed bottle brotli certifi cffi charset-normalizer click click-default-group coloredlogs configargparse cryptography cssselect2 dashing dataclass-wizard deepl deprecated distro docformatter dsnparse duckdb fastapi ffmpy filelock flatbuffers fonttools freetype-py fsspec gradio gradio-client gradio-pdf greenlet groovy h11 harlequin harlequin-mysql html5lib httpcore httpx huggingface-hub humanfriendly idna imageio isodate jinja2 jiter jmespath lazy-loader levenshtein libtmux linkify-it-py lxml markdown-it-py markupsafe mdit-py-plugins mdurl mpmath msgpack mysql-connector-python netaddr networkx numpy ollama onnx onnxruntime openai opencv-python opencv-python-headless orjson packaging pandas pbr pdf2zh pdfminer-six peewee pikepdf pillow pip platformdirs presenterm-export prompt-toolkit protobuf psutil pyarrow pyclipper pycparser pydantic pydantic-core pydub pydyf pygame pygments pymupdf pynvim pyperclip pyphen python-dateutil python-levenshtein python-multipart pytimeparse2 pytz pyyaml questionary rapidfuzz rapidocr-onnxruntime regex requests resolvelib rich rich-click ruamel-yaml ruamel-yaml-clib ruff safehttpx scikit-image scipy semantic-version setuptools shandy-sqlfmt shapely shellingham simplejson six sniffio socksio sqlite3-to-mysql starlette sympy tabulate tenacity tencentcloud-sdk-python tencentcloud-sdk-python-common tencentcloud-sdk-python-tmt termcolor textual textual-fastdatatable textual-textarea tifffile tiktoken tinycss2 toml tomlkit toposort tqdm tree-sitter tree-sitter-bash tree-sitter-css tree-sitter-go tree-sitter-html tree-sitter-java tree-sitter-javascript tree-sitter-json tree-sitter-languages tree-sitter-markdown tree-sitter-python tree-sitter-regex tree-sitter-rust tree-sitter-sql tree-sitter-toml tree-sitter-xml tree-sitter-yaml typer types-python-dateutil typing-extensions typing-inspection tzdata uc-micro-py unidecode unimatrix untokenize urllib3 uv uvicorn wcwidth weasyprint webencodings websockets wrapt xinference-client xsdata zopfli  ${additional_for_uv_pip_option}

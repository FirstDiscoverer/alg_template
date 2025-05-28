import logging
import re

from fastapi import APIRouter
from markdown import markdown
from pygments.formatters.html import HtmlFormatter
from starlette.responses import HTMLResponse

from src.config.base import base_config

logger = logging.getLogger(__name__)
router = APIRouter()

DEFAULT_MD_PATH = base_config.join_path('docs', 'Api文档.md')


def get_md_html(path=DEFAULT_MD_PATH):
    with open(path, encoding='utf-8') as f:
        md_str = f.read()
    # 插入 TOC 占位符
    md_str = "[TOC]\n\n" + md_str

    # [Extensions](https://python-markdown.github.io/extensions)
    extensions = [
        'fenced_code',  # 支持代码块
        'codehilite',  # 代码语法高亮
        'tables',  # 表格支持
        'toc',  # 目录支持
    ]
    md = markdown(md_str, extensions=extensions)
    return md


html_template = """
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>API 文档</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        * {{
            box-sizing: border-box;
        }}
        body {{
            margin: 0;
            font-family: "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            display: flex;
            height: 100vh;
            background-color: #ffffff;
            color: #333;
        }}
        nav {{
            width: 280px;
            background-color: #f7f9fb;
            border-right: 1px solid #e0e0e0;
            padding: 30px 24px 40px 24px;
            overflow-y: auto;
        }}
        main {{
            flex: 1;
            padding: 40px 60px;
            overflow-y: auto;
        }}

        /* TOC 样式 */
        .toc {{
            font-size: 15px;
            line-height: 1.6;
            padding-left: 16px;
        }}
        .toc ul {{
            list-style: none;
            padding-left: 0;
            margin: 0;
        }}
        .toc li {{
            margin: 6px 0;
        }}
        .toc a {{
            color: #1976d2;
            text-decoration: none;
            padding: 4px 0;
            display: block;
        }}
        .toc a:hover {{
            color: #125699;
            text-decoration: underline;
        }}
        .toc ul ul,
        .toc ul ul ul,
        .toc ul ul ul ul {{
            padding-left: 16px;
        }}

        /* 表格样式 */
        table {{
            border-collapse: collapse;
            width: 100%;
            margin: 20px 0;
        }}
        th, td {{
            border: 1px solid #ddd;
            padding: 12px 16px;
        }}
        th {{
            background-color: #f1f1f1;
        }}
        tr:nth-child(even) {{
            background-color: #fafafa;
        }}

        /* 代码高亮 */
        {css_styles}

        /* 响应式优化 */
        @media (max-width: 768px) {{
            body {{
                flex-direction: column;
            }}
            nav {{
                width: 100%;
                border-right: none;
                border-bottom: 1px solid #e0e0e0;
            }}
            main {{
                padding: 20px;
            }}
        }}
    </style>
</head>
<body>
    <div class="toc">
        {md_html_toc}
    </div>
    <main>
        {md_html_content}
    </main>
</body>
</html>
"""


@router.get("/docs/md")
def docs(style: str = 'material'):
    # styles = list(pygments.styles.get_all_styles())
    # print(f"markdown css style: {json.dumps(styles, ensure_ascii=False)}")

    # [Markdown to HTML](https://wangjunjian.com/restapi/2023/10/04/fastapi-development-restapi-practice.html)
    formatter = HtmlFormatter(style=style, cssclass='codehilite')
    css_styles = formatter.get_style_defs('.codehilite')

    md_html = get_md_html()  # 每次均重新读取，避免更新docs后需要重启服务

    # 提取 TOC
    toc_match = re.search(r'(<div class="toc">.*?</div>)', md_html, re.DOTALL)
    if toc_match:
        md_html_toc = toc_match.group(1)
        md_html_content = md_html.replace(md_html_toc, '')
    else:
        md_html_toc = "<p><em>未生成目录</em></p>"
        md_html_content = md_html

    html_content = html_template.format(
        css_styles=css_styles,
        md_html_toc=md_html_toc,
        md_html_content=md_html_content
    )

    return HTMLResponse(content=html_content)

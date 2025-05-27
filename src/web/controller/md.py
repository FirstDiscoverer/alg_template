import logging

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
    # [Extensions](https://python-markdown.github.io/extensions)
    extensions = [
        'fenced_code',  # 支持代码块
        'codehilite',  # 代码语法高亮
        'tables'  # 新增表格支持
    ]
    md = markdown(md_str, extensions=extensions)
    return md


html_template = """
<html>
    <head>
        <title>Api文档</title>
        <style>
            body {{ width: 60%; margin: auto; }}

             /* 表格样式 */
            table {{
                border-collapse: collapse;
                margin: 1em 0;
                width: 100%;
                box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            }}
            th, td {{
                border: 1px solid #ddd;
                padding: 12px 15px;
                text-align: left;
            }}
            th {{
                background-color: #f8f9fa;
                font-weight: 600;
            }}
            tr:nth-child(even) {{
                background-color: #f9f9f9;
            }}

            /* 代码块样式 */
            {css_styles}
        </style>
    </head>
    <body>
        {md_html}
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
    html_content = html_template.format(css_styles=css_styles, md_html=md_html)
    return HTMLResponse(content=html_content)

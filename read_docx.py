import zipfile
import xml.etree.ElementTree as ET
import sys

def get_docx_text(path):
    docx = zipfile.ZipFile(path)
    xml = docx.read('word/document.xml')
    tree = ET.fromstring(xml)
    texts = []
    for p in tree.iter('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}p'):
        para_text = []
        for r in p.iter('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}t'):
            if r.text:
                para_text.append(r.text)
        if para_text:
            texts.append(''.join(para_text))
    return '\n'.join(texts)

for f in sys.argv[1:]:
    print(f'=== {f} ===')
    print(get_docx_text(f))
    print('\n')

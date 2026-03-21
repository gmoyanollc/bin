#/usr/bin/bash

pdf_filename=${1}

pdftoppm -jpeg ${pdf_filename} ${pdf_filename}

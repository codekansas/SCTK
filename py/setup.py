#!/usr/bin/env python

import os
import glob
import sys
from setuptools import setup, find_packages, Extension

if sys.version_info < (3, 6):
    sys.exit("Sorry, Python >= 3.6 is required.")

with open("README.md") as f:
    readme = f.read()

sources = []
sources += glob.glob(os.path.join(os.pardir, "src/**/*.c"))
sources += glob.glob("src/*.c")

module = Extension("sctk", sources=sources)

setup(name="sctk-py",
      version="0.0.1",
      description="Speech Recognition Scoring Toolkit",
      classifiers=[
          "Intended Audience :: Science/Research",
          "Topic :: Scientific/Engineering :: Artificial Intelligence",
      ],
      long_description=readme,
      long_description_content_type="text/markdown",
      setup_requires=["setuptools>=18.0"],
      install_requires=[],
      packages=find_packages(exclude=["tests"]),
      ext_modules=[module],
      test_suite="tests",
      zip_safe=False)

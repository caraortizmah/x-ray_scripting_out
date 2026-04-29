#!/usr/bin/env python
"""
Setup script for x-ray-quantumol-parser package.

This is a compatibility layer for legacy build tools.
Modern builds should use: python -m build
"""

from setuptools import setup, find_packages

setup(
    packages=find_packages(exclude=["tests", "tests.*", "examples", "output", "input"]),
)

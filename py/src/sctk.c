#include <Python.h>

#define MAIN
#include "sctk.h"

static PyObject *sctk_sclite(PyObject *self, PyObject *args) {
  char *ref, *hyp;

  if (!PyArg_ParseTuple(args, "ss", &ref, &hyp))
    return NULL;

  return PyLong_FromLong(strlen(ref) + strlen(hyp));
}

static PyMethodDef sctk_methods[] = {
    {"sclite", sctk_sclite, METH_VARARGS, "Run SCLite."},
    {NULL, NULL, 0, NULL} /* sentinel */
};

static struct PyModuleDef sctkmodule = {
    PyModuleDef_HEAD_INIT, "sctk", NULL, -1, sctk_methods,
};

PyMODINIT_FUNC PyInit_sctk(void) { return PyModule_Create(&sctkmodule); }

/*
 * ATTENTION: An "eval-source-map" devtool has been used.
 * This devtool is neither made for production nor for readable output files.
 * It uses "eval()" calls to create a separate source file with attached SourceMaps in the browser devtools.
 * If you are trying to read the output file, select a different devtool (https://webpack.js.org/configuration/devtool/)
 * or disable the default devtool with "devtool: false".
 * If you are looking for production-ready output files, see mode: "production" (https://webpack.js.org/configuration/mode/).
 */
exports.id = "vendor-chunks/cross-fetch";
exports.ids = ["vendor-chunks/cross-fetch"];
exports.modules = {

/***/ "(ssr)/./node_modules/cross-fetch/dist/node-ponyfill.js":
/*!********************************************************!*\
  !*** ./node_modules/cross-fetch/dist/node-ponyfill.js ***!
  \********************************************************/
/***/ ((module, exports, __webpack_require__) => {

eval("const nodeFetch = __webpack_require__(/*! node-fetch */ \"(ssr)/./node_modules/node-fetch/lib/index.mjs\");\nconst realFetch = nodeFetch.default || nodeFetch;\nconst fetch = function(url, options) {\n    // Support schemaless URIs on the server for parity with the browser.\n    // Ex: //github.com/ -> https://github.com/\n    if (/^\\/\\//.test(url)) {\n        url = \"https:\" + url;\n    }\n    return realFetch.call(this, url, options);\n};\nfetch.ponyfill = true;\nmodule.exports = exports = fetch;\nexports.fetch = fetch;\nexports.Headers = nodeFetch.Headers;\nexports.Request = nodeFetch.Request;\nexports.Response = nodeFetch.Response;\n// Needed for TypeScript consumers without esModuleInterop.\nexports[\"default\"] = fetch;\n//# sourceURL=[module]\n//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiKHNzcikvLi9ub2RlX21vZHVsZXMvY3Jvc3MtZmV0Y2gvZGlzdC9ub2RlLXBvbnlmaWxsLmpzIiwibWFwcGluZ3MiOiJBQUFBLE1BQU1BLFlBQVlDLG1CQUFPQSxDQUFDO0FBQzFCLE1BQU1DLFlBQVlGLFVBQVVHLE9BQU8sSUFBSUg7QUFFdkMsTUFBTUksUUFBUSxTQUFVQyxHQUFHLEVBQUVDLE9BQU87SUFDbEMscUVBQXFFO0lBQ3JFLDJDQUEyQztJQUMzQyxJQUFJLFFBQVFDLElBQUksQ0FBQ0YsTUFBTTtRQUNyQkEsTUFBTSxXQUFXQTtJQUNuQjtJQUNBLE9BQU9ILFVBQVVNLElBQUksQ0FBQyxJQUFJLEVBQUVILEtBQUtDO0FBQ25DO0FBRUFGLE1BQU1LLFFBQVEsR0FBRztBQUVqQkMsT0FBT0MsT0FBTyxHQUFHQSxVQUFVUDtBQUMzQk8sYUFBYSxHQUFHUDtBQUNoQk8sZUFBZSxHQUFHWCxVQUFVWSxPQUFPO0FBQ25DRCxlQUFlLEdBQUdYLFVBQVVhLE9BQU87QUFDbkNGLGdCQUFnQixHQUFHWCxVQUFVYyxRQUFRO0FBRXJDLDJEQUEyRDtBQUMzREgsa0JBQWUsR0FBR1AiLCJzb3VyY2VzIjpbIndlYnBhY2s6Ly9mcm9udC8uL25vZGVfbW9kdWxlcy9jcm9zcy1mZXRjaC9kaXN0L25vZGUtcG9ueWZpbGwuanM/NTM3YSJdLCJzb3VyY2VzQ29udGVudCI6WyJjb25zdCBub2RlRmV0Y2ggPSByZXF1aXJlKCdub2RlLWZldGNoJylcbmNvbnN0IHJlYWxGZXRjaCA9IG5vZGVGZXRjaC5kZWZhdWx0IHx8IG5vZGVGZXRjaFxuXG5jb25zdCBmZXRjaCA9IGZ1bmN0aW9uICh1cmwsIG9wdGlvbnMpIHtcbiAgLy8gU3VwcG9ydCBzY2hlbWFsZXNzIFVSSXMgb24gdGhlIHNlcnZlciBmb3IgcGFyaXR5IHdpdGggdGhlIGJyb3dzZXIuXG4gIC8vIEV4OiAvL2dpdGh1Yi5jb20vIC0+IGh0dHBzOi8vZ2l0aHViLmNvbS9cbiAgaWYgKC9eXFwvXFwvLy50ZXN0KHVybCkpIHtcbiAgICB1cmwgPSAnaHR0cHM6JyArIHVybFxuICB9XG4gIHJldHVybiByZWFsRmV0Y2guY2FsbCh0aGlzLCB1cmwsIG9wdGlvbnMpXG59XG5cbmZldGNoLnBvbnlmaWxsID0gdHJ1ZVxuXG5tb2R1bGUuZXhwb3J0cyA9IGV4cG9ydHMgPSBmZXRjaFxuZXhwb3J0cy5mZXRjaCA9IGZldGNoXG5leHBvcnRzLkhlYWRlcnMgPSBub2RlRmV0Y2guSGVhZGVyc1xuZXhwb3J0cy5SZXF1ZXN0ID0gbm9kZUZldGNoLlJlcXVlc3RcbmV4cG9ydHMuUmVzcG9uc2UgPSBub2RlRmV0Y2guUmVzcG9uc2VcblxuLy8gTmVlZGVkIGZvciBUeXBlU2NyaXB0IGNvbnN1bWVycyB3aXRob3V0IGVzTW9kdWxlSW50ZXJvcC5cbmV4cG9ydHMuZGVmYXVsdCA9IGZldGNoXG4iXSwibmFtZXMiOlsibm9kZUZldGNoIiwicmVxdWlyZSIsInJlYWxGZXRjaCIsImRlZmF1bHQiLCJmZXRjaCIsInVybCIsIm9wdGlvbnMiLCJ0ZXN0IiwiY2FsbCIsInBvbnlmaWxsIiwibW9kdWxlIiwiZXhwb3J0cyIsIkhlYWRlcnMiLCJSZXF1ZXN0IiwiUmVzcG9uc2UiXSwic291cmNlUm9vdCI6IiJ9\n//# sourceURL=webpack-internal:///(ssr)/./node_modules/cross-fetch/dist/node-ponyfill.js\n");

/***/ })

};
;
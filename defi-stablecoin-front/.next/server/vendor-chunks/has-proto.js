"use strict";
/*
 * ATTENTION: An "eval-source-map" devtool has been used.
 * This devtool is neither made for production nor for readable output files.
 * It uses "eval()" calls to create a separate source file with attached SourceMaps in the browser devtools.
 * If you are trying to read the output file, select a different devtool (https://webpack.js.org/configuration/devtool/)
 * or disable the default devtool with "devtool: false".
 * If you are looking for production-ready output files, see mode: "production" (https://webpack.js.org/configuration/mode/).
 */
exports.id = "vendor-chunks/has-proto";
exports.ids = ["vendor-chunks/has-proto"];
exports.modules = {

/***/ "(ssr)/./node_modules/has-proto/index.js":
/*!*****************************************!*\
  !*** ./node_modules/has-proto/index.js ***!
  \*****************************************/
/***/ ((module) => {

eval("\nvar test = {\n    foo: {}\n};\nvar $Object = Object;\nmodule.exports = function hasProto() {\n    return ({\n        __proto__: test\n    }).foo === test.foo && !(({\n        __proto__: null\n    }) instanceof $Object);\n};\n//# sourceURL=[module]\n//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiKHNzcikvLi9ub2RlX21vZHVsZXMvaGFzLXByb3RvL2luZGV4LmpzIiwibWFwcGluZ3MiOiJBQUFBO0FBRUEsSUFBSUEsT0FBTztJQUNWQyxLQUFLLENBQUM7QUFDUDtBQUVBLElBQUlDLFVBQVVDO0FBRWRDLE9BQU9DLE9BQU8sR0FBRyxTQUFTQztJQUN6QixPQUFPO1FBQUVDLFdBQVdQO0lBQUssR0FBRUMsR0FBRyxLQUFLRCxLQUFLQyxHQUFHLElBQUksQ0FBRTtRQUFFTSxXQUFXO0lBQUssY0FBYUwsT0FBTTtBQUN2RiIsInNvdXJjZXMiOlsid2VicGFjazovL2Zyb250Ly4vbm9kZV9tb2R1bGVzL2hhcy1wcm90by9pbmRleC5qcz82ZjAyIl0sInNvdXJjZXNDb250ZW50IjpbIid1c2Ugc3RyaWN0JztcblxudmFyIHRlc3QgPSB7XG5cdGZvbzoge31cbn07XG5cbnZhciAkT2JqZWN0ID0gT2JqZWN0O1xuXG5tb2R1bGUuZXhwb3J0cyA9IGZ1bmN0aW9uIGhhc1Byb3RvKCkge1xuXHRyZXR1cm4geyBfX3Byb3RvX186IHRlc3QgfS5mb28gPT09IHRlc3QuZm9vICYmICEoeyBfX3Byb3RvX186IG51bGwgfSBpbnN0YW5jZW9mICRPYmplY3QpO1xufTtcbiJdLCJuYW1lcyI6WyJ0ZXN0IiwiZm9vIiwiJE9iamVjdCIsIk9iamVjdCIsIm1vZHVsZSIsImV4cG9ydHMiLCJoYXNQcm90byIsIl9fcHJvdG9fXyJdLCJzb3VyY2VSb290IjoiIn0=\n//# sourceURL=webpack-internal:///(ssr)/./node_modules/has-proto/index.js\n");

/***/ })

};
;
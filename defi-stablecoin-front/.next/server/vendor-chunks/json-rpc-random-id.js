/*
 * ATTENTION: An "eval-source-map" devtool has been used.
 * This devtool is neither made for production nor for readable output files.
 * It uses "eval()" calls to create a separate source file with attached SourceMaps in the browser devtools.
 * If you are trying to read the output file, select a different devtool (https://webpack.js.org/configuration/devtool/)
 * or disable the default devtool with "devtool: false".
 * If you are looking for production-ready output files, see mode: "production" (https://webpack.js.org/configuration/mode/).
 */
exports.id = "vendor-chunks/json-rpc-random-id";
exports.ids = ["vendor-chunks/json-rpc-random-id"];
exports.modules = {

/***/ "(ssr)/./node_modules/json-rpc-random-id/index.js":
/*!**************************************************!*\
  !*** ./node_modules/json-rpc-random-id/index.js ***!
  \**************************************************/
/***/ ((module) => {

eval("module.exports = IdIterator;\nfunction IdIterator(opts) {\n    opts = opts || {};\n    var max = opts.max || Number.MAX_SAFE_INTEGER;\n    var idCounter = typeof opts.start !== \"undefined\" ? opts.start : Math.floor(Math.random() * max);\n    return function createRandomId() {\n        idCounter = idCounter % max;\n        return idCounter++;\n    };\n}\n//# sourceURL=[module]\n//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIndlYnBhY2s6Ly9mcm9udC8uL25vZGVfbW9kdWxlcy9qc29uLXJwYy1yYW5kb20taWQvaW5kZXguanM/ODFkNiJdLCJzb3VyY2VzQ29udGVudCI6WyJtb2R1bGUuZXhwb3J0cyA9IElkSXRlcmF0b3JcblxuZnVuY3Rpb24gSWRJdGVyYXRvcihvcHRzKXtcbiAgb3B0cyA9IG9wdHMgfHwge31cbiAgdmFyIG1heCA9IG9wdHMubWF4IHx8IE51bWJlci5NQVhfU0FGRV9JTlRFR0VSXG4gIHZhciBpZENvdW50ZXIgPSB0eXBlb2Ygb3B0cy5zdGFydCAhPT0gJ3VuZGVmaW5lZCcgPyBvcHRzLnN0YXJ0IDogTWF0aC5mbG9vcihNYXRoLnJhbmRvbSgpICogbWF4KVxuXG4gIHJldHVybiBmdW5jdGlvbiBjcmVhdGVSYW5kb21JZCAoKSB7XG4gICAgaWRDb3VudGVyID0gaWRDb3VudGVyICUgbWF4XG4gICAgcmV0dXJuIGlkQ291bnRlcisrXG4gIH1cblxufSJdLCJuYW1lcyI6WyJtb2R1bGUiLCJleHBvcnRzIiwiSWRJdGVyYXRvciIsIm9wdHMiLCJtYXgiLCJOdW1iZXIiLCJNQVhfU0FGRV9JTlRFR0VSIiwiaWRDb3VudGVyIiwic3RhcnQiLCJNYXRoIiwiZmxvb3IiLCJyYW5kb20iLCJjcmVhdGVSYW5kb21JZCJdLCJtYXBwaW5ncyI6IkFBQUFBLE9BQU9DLE9BQU8sR0FBR0M7QUFFakIsU0FBU0EsV0FBV0MsSUFBSTtJQUN0QkEsT0FBT0EsUUFBUSxDQUFDO0lBQ2hCLElBQUlDLE1BQU1ELEtBQUtDLEdBQUcsSUFBSUMsT0FBT0MsZ0JBQWdCO0lBQzdDLElBQUlDLFlBQVksT0FBT0osS0FBS0ssS0FBSyxLQUFLLGNBQWNMLEtBQUtLLEtBQUssR0FBR0MsS0FBS0MsS0FBSyxDQUFDRCxLQUFLRSxNQUFNLEtBQUtQO0lBRTVGLE9BQU8sU0FBU1E7UUFDZEwsWUFBWUEsWUFBWUg7UUFDeEIsT0FBT0c7SUFDVDtBQUVGIiwiZmlsZSI6Iihzc3IpLy4vbm9kZV9tb2R1bGVzL2pzb24tcnBjLXJhbmRvbS1pZC9pbmRleC5qcyIsInNvdXJjZVJvb3QiOiIifQ==\n//# sourceURL=webpack-internal:///(ssr)/./node_modules/json-rpc-random-id/index.js\n");

/***/ })

};
;
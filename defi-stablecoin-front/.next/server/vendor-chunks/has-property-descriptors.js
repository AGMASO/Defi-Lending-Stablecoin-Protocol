"use strict";
/*
 * ATTENTION: An "eval-source-map" devtool has been used.
 * This devtool is neither made for production nor for readable output files.
 * It uses "eval()" calls to create a separate source file with attached SourceMaps in the browser devtools.
 * If you are trying to read the output file, select a different devtool (https://webpack.js.org/configuration/devtool/)
 * or disable the default devtool with "devtool: false".
 * If you are looking for production-ready output files, see mode: "production" (https://webpack.js.org/configuration/mode/).
 */
exports.id = "vendor-chunks/has-property-descriptors";
exports.ids = ["vendor-chunks/has-property-descriptors"];
exports.modules = {

/***/ "(ssr)/./node_modules/has-property-descriptors/index.js":
/*!********************************************************!*\
  !*** ./node_modules/has-property-descriptors/index.js ***!
  \********************************************************/
/***/ ((module, __unused_webpack_exports, __webpack_require__) => {

eval("\nvar GetIntrinsic = __webpack_require__(/*! get-intrinsic */ \"(ssr)/./node_modules/get-intrinsic/index.js\");\nvar $defineProperty = GetIntrinsic(\"%Object.defineProperty%\", true);\nvar hasPropertyDescriptors = function hasPropertyDescriptors() {\n    if ($defineProperty) {\n        try {\n            $defineProperty({}, \"a\", {\n                value: 1\n            });\n            return true;\n        } catch (e) {\n            // IE 8 has a broken defineProperty\n            return false;\n        }\n    }\n    return false;\n};\nhasPropertyDescriptors.hasArrayLengthDefineBug = function hasArrayLengthDefineBug() {\n    // node v0.6 has a bug where array lengths can be Set but not Defined\n    if (!hasPropertyDescriptors()) {\n        return null;\n    }\n    try {\n        return $defineProperty([], \"length\", {\n            value: 1\n        }).length !== 1;\n    } catch (e) {\n        // In Firefox 4-22, defining length on an array throws an exception.\n        return true;\n    }\n};\nmodule.exports = hasPropertyDescriptors;\n//# sourceURL=[module]\n//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiKHNzcikvLi9ub2RlX21vZHVsZXMvaGFzLXByb3BlcnR5LWRlc2NyaXB0b3JzL2luZGV4LmpzIiwibWFwcGluZ3MiOiJBQUFBO0FBRUEsSUFBSUEsZUFBZUMsbUJBQU9BLENBQUM7QUFFM0IsSUFBSUMsa0JBQWtCRixhQUFhLDJCQUEyQjtBQUU5RCxJQUFJRyx5QkFBeUIsU0FBU0E7SUFDckMsSUFBSUQsaUJBQWlCO1FBQ3BCLElBQUk7WUFDSEEsZ0JBQWdCLENBQUMsR0FBRyxLQUFLO2dCQUFFRSxPQUFPO1lBQUU7WUFDcEMsT0FBTztRQUNSLEVBQUUsT0FBT0MsR0FBRztZQUNYLG1DQUFtQztZQUNuQyxPQUFPO1FBQ1I7SUFDRDtJQUNBLE9BQU87QUFDUjtBQUVBRix1QkFBdUJHLHVCQUF1QixHQUFHLFNBQVNBO0lBQ3pELHFFQUFxRTtJQUNyRSxJQUFJLENBQUNILDBCQUEwQjtRQUM5QixPQUFPO0lBQ1I7SUFDQSxJQUFJO1FBQ0gsT0FBT0QsZ0JBQWdCLEVBQUUsRUFBRSxVQUFVO1lBQUVFLE9BQU87UUFBRSxHQUFHRyxNQUFNLEtBQUs7SUFDL0QsRUFBRSxPQUFPRixHQUFHO1FBQ1gsb0VBQW9FO1FBQ3BFLE9BQU87SUFDUjtBQUNEO0FBRUFHLE9BQU9DLE9BQU8sR0FBR04iLCJzb3VyY2VzIjpbIndlYnBhY2s6Ly9mcm9udC8uL25vZGVfbW9kdWxlcy9oYXMtcHJvcGVydHktZGVzY3JpcHRvcnMvaW5kZXguanM/ZDk3ZiJdLCJzb3VyY2VzQ29udGVudCI6WyIndXNlIHN0cmljdCc7XG5cbnZhciBHZXRJbnRyaW5zaWMgPSByZXF1aXJlKCdnZXQtaW50cmluc2ljJyk7XG5cbnZhciAkZGVmaW5lUHJvcGVydHkgPSBHZXRJbnRyaW5zaWMoJyVPYmplY3QuZGVmaW5lUHJvcGVydHklJywgdHJ1ZSk7XG5cbnZhciBoYXNQcm9wZXJ0eURlc2NyaXB0b3JzID0gZnVuY3Rpb24gaGFzUHJvcGVydHlEZXNjcmlwdG9ycygpIHtcblx0aWYgKCRkZWZpbmVQcm9wZXJ0eSkge1xuXHRcdHRyeSB7XG5cdFx0XHQkZGVmaW5lUHJvcGVydHkoe30sICdhJywgeyB2YWx1ZTogMSB9KTtcblx0XHRcdHJldHVybiB0cnVlO1xuXHRcdH0gY2F0Y2ggKGUpIHtcblx0XHRcdC8vIElFIDggaGFzIGEgYnJva2VuIGRlZmluZVByb3BlcnR5XG5cdFx0XHRyZXR1cm4gZmFsc2U7XG5cdFx0fVxuXHR9XG5cdHJldHVybiBmYWxzZTtcbn07XG5cbmhhc1Byb3BlcnR5RGVzY3JpcHRvcnMuaGFzQXJyYXlMZW5ndGhEZWZpbmVCdWcgPSBmdW5jdGlvbiBoYXNBcnJheUxlbmd0aERlZmluZUJ1ZygpIHtcblx0Ly8gbm9kZSB2MC42IGhhcyBhIGJ1ZyB3aGVyZSBhcnJheSBsZW5ndGhzIGNhbiBiZSBTZXQgYnV0IG5vdCBEZWZpbmVkXG5cdGlmICghaGFzUHJvcGVydHlEZXNjcmlwdG9ycygpKSB7XG5cdFx0cmV0dXJuIG51bGw7XG5cdH1cblx0dHJ5IHtcblx0XHRyZXR1cm4gJGRlZmluZVByb3BlcnR5KFtdLCAnbGVuZ3RoJywgeyB2YWx1ZTogMSB9KS5sZW5ndGggIT09IDE7XG5cdH0gY2F0Y2ggKGUpIHtcblx0XHQvLyBJbiBGaXJlZm94IDQtMjIsIGRlZmluaW5nIGxlbmd0aCBvbiBhbiBhcnJheSB0aHJvd3MgYW4gZXhjZXB0aW9uLlxuXHRcdHJldHVybiB0cnVlO1xuXHR9XG59O1xuXG5tb2R1bGUuZXhwb3J0cyA9IGhhc1Byb3BlcnR5RGVzY3JpcHRvcnM7XG4iXSwibmFtZXMiOlsiR2V0SW50cmluc2ljIiwicmVxdWlyZSIsIiRkZWZpbmVQcm9wZXJ0eSIsImhhc1Byb3BlcnR5RGVzY3JpcHRvcnMiLCJ2YWx1ZSIsImUiLCJoYXNBcnJheUxlbmd0aERlZmluZUJ1ZyIsImxlbmd0aCIsIm1vZHVsZSIsImV4cG9ydHMiXSwic291cmNlUm9vdCI6IiJ9\n//# sourceURL=webpack-internal:///(ssr)/./node_modules/has-property-descriptors/index.js\n");

/***/ })

};
;
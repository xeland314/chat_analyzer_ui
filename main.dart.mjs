// Compiles a dart2wasm-generated main module from `source` which can then
// instantiatable via the `instantiate` method.
//
// `source` needs to be a `Response` object (or promise thereof) e.g. created
// via the `fetch()` JS API.
export async function compileStreaming(source) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(
      await WebAssembly.compileStreaming(source, builtins), builtins);
}

// Compiles a dart2wasm-generated wasm modules from `bytes` which is then
// instantiatable via the `instantiate` method.
export async function compile(bytes) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(await WebAssembly.compile(bytes, builtins), builtins);
}

// DEPRECATED: Please use `compile` or `compileStreaming` to get a compiled app,
// use `instantiate` method to get an instantiated app and then call
// `invokeMain` to invoke the main function.
export async function instantiate(modulePromise, importObjectPromise) {
  var moduleOrCompiledApp = await modulePromise;
  if (!(moduleOrCompiledApp instanceof CompiledApp)) {
    moduleOrCompiledApp = new CompiledApp(moduleOrCompiledApp);
  }
  const instantiatedApp = await moduleOrCompiledApp.instantiate(await importObjectPromise);
  return instantiatedApp.instantiatedModule;
}

// DEPRECATED: Please use `compile` or `compileStreaming` to get a compiled app,
// use `instantiate` method to get an instantiated app and then call
// `invokeMain` to invoke the main function.
export const invoke = (moduleInstance, ...args) => {
  moduleInstance.exports.$invokeMain(args);
}

class CompiledApp {
  constructor(module, builtins) {
    this.module = module;
    this.builtins = builtins;
  }

  // The second argument is an options object containing:
  // `loadDeferredWasm` is a JS function that takes a module name matching a
  //   wasm file produced by the dart2wasm compiler and returns the bytes to
  //   load the module. These bytes can be in either a format supported by
  //   `WebAssembly.compile` or `WebAssembly.compileStreaming`.
  // `loadDynamicModule` is a JS function that takes two string names matching,
  //   in order, a wasm file produced by the dart2wasm compiler during dynamic
  //   module compilation and a corresponding js file produced by the same
  //   compilation. It should return a JS Array containing 2 elements. The first
  //   should be the bytes for the wasm module in a format supported by
  //   `WebAssembly.compile` or `WebAssembly.compileStreaming`. The second
  //   should be the result of using the JS 'import' API on the js file path.
  async instantiate(additionalImports, {loadDeferredWasm, loadDynamicModule} = {}) {
    let dartInstance;

    // Prints to the console
    function printToConsole(value) {
      if (typeof dartPrint == "function") {
        dartPrint(value);
        return;
      }
      if (typeof console == "object" && typeof console.log != "undefined") {
        console.log(value);
        return;
      }
      if (typeof print == "function") {
        print(value);
        return;
      }

      throw "Unable to print message: " + value;
    }

    // A special symbol attached to functions that wrap Dart functions.
    const jsWrappedDartFunctionSymbol = Symbol("JSWrappedDartFunction");

    function finalizeWrapper(dartFunction, wrapped) {
      wrapped.dartFunction = dartFunction;
      wrapped[jsWrappedDartFunctionSymbol] = true;
      return wrapped;
    }

    // Imports
    const dart2wasm = {
            _4: (o, c) => o instanceof c,
      _7: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._7(f,arguments.length,x0) }),
      _8: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._8(f,arguments.length,x0,x1) }),
      _9: (o, a) => o + a,
      _37: x0 => new Array(x0),
      _39: x0 => x0.length,
      _41: (x0,x1) => x0[x1],
      _42: (x0,x1,x2) => { x0[x1] = x2 },
      _43: x0 => new Promise(x0),
      _45: (x0,x1,x2) => new DataView(x0,x1,x2),
      _47: x0 => new Int8Array(x0),
      _48: (x0,x1,x2) => new Uint8Array(x0,x1,x2),
      _49: x0 => new Uint8Array(x0),
      _51: x0 => new Uint8ClampedArray(x0),
      _53: x0 => new Int16Array(x0),
      _55: x0 => new Uint16Array(x0),
      _57: x0 => new Int32Array(x0),
      _59: x0 => new Uint32Array(x0),
      _61: x0 => new Float32Array(x0),
      _63: x0 => new Float64Array(x0),
      _65: (x0,x1,x2) => x0.call(x1,x2),
      _70: (decoder, codeUnits) => decoder.decode(codeUnits),
      _71: () => new TextDecoder("utf-8", {fatal: true}),
      _72: () => new TextDecoder("utf-8", {fatal: false}),
      _73: (s) => +s,
      _74: x0 => new Uint8Array(x0),
      _75: (x0,x1,x2) => x0.set(x1,x2),
      _76: (x0,x1) => x0.transferFromImageBitmap(x1),
      _78: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._78(f,arguments.length,x0) }),
      _79: x0 => new window.FinalizationRegistry(x0),
      _80: (x0,x1,x2,x3) => x0.register(x1,x2,x3),
      _81: (x0,x1) => x0.unregister(x1),
      _82: (x0,x1,x2) => x0.slice(x1,x2),
      _83: (x0,x1) => x0.decode(x1),
      _84: (x0,x1) => x0.segment(x1),
      _85: () => new TextDecoder(),
      _87: x0 => x0.click(),
      _88: x0 => x0.buffer,
      _89: x0 => x0.wasmMemory,
      _90: () => globalThis.window._flutter_skwasmInstance,
      _91: x0 => x0.rasterStartMilliseconds,
      _92: x0 => x0.rasterEndMilliseconds,
      _93: x0 => x0.imageBitmaps,
      _120: x0 => x0.remove(),
      _121: (x0,x1) => x0.append(x1),
      _122: (x0,x1,x2) => x0.insertBefore(x1,x2),
      _123: (x0,x1) => x0.querySelector(x1),
      _125: (x0,x1) => x0.removeChild(x1),
      _203: x0 => x0.stopPropagation(),
      _204: x0 => x0.preventDefault(),
      _206: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      _251: x0 => x0.unlock(),
      _252: x0 => x0.getReader(),
      _253: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _254: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      _255: (x0,x1) => x0.item(x1),
      _256: x0 => x0.next(),
      _257: x0 => x0.now(),
      _258: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._258(f,arguments.length,x0) }),
      _259: (x0,x1) => x0.addListener(x1),
      _260: (x0,x1) => x0.removeListener(x1),
      _261: (x0,x1) => x0.matchMedia(x1),
      _268: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._268(f,arguments.length,x0) }),
      _269: (x0,x1) => x0.getModifierState(x1),
      _270: (x0,x1) => x0.removeProperty(x1),
      _271: (x0,x1) => x0.prepend(x1),
      _272: x0 => x0.disconnect(),
      _273: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._273(f,arguments.length,x0) }),
      _274: (x0,x1) => x0.getAttribute(x1),
      _275: (x0,x1) => x0.contains(x1),
      _276: x0 => x0.blur(),
      _277: x0 => x0.hasFocus(),
      _278: (x0,x1) => x0.hasAttribute(x1),
      _279: (x0,x1) => x0.getModifierState(x1),
      _280: (x0,x1) => x0.appendChild(x1),
      _281: (x0,x1) => x0.createTextNode(x1),
      _282: (x0,x1) => x0.removeAttribute(x1),
      _283: x0 => x0.getBoundingClientRect(),
      _284: (x0,x1) => x0.observe(x1),
      _285: x0 => x0.disconnect(),
      _286: (x0,x1) => x0.closest(x1),
      _696: () => globalThis.window.flutterConfiguration,
      _697: x0 => x0.assetBase,
      _703: x0 => x0.debugShowSemanticsNodes,
      _704: x0 => x0.hostElement,
      _705: x0 => x0.multiViewEnabled,
      _706: x0 => x0.nonce,
      _708: x0 => x0.fontFallbackBaseUrl,
      _712: x0 => x0.console,
      _713: x0 => x0.devicePixelRatio,
      _714: x0 => x0.document,
      _715: x0 => x0.history,
      _716: x0 => x0.innerHeight,
      _717: x0 => x0.innerWidth,
      _718: x0 => x0.location,
      _719: x0 => x0.navigator,
      _720: x0 => x0.visualViewport,
      _721: x0 => x0.performance,
      _725: (x0,x1) => x0.getComputedStyle(x1),
      _726: x0 => x0.screen,
      _727: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._727(f,arguments.length,x0) }),
      _728: (x0,x1) => x0.requestAnimationFrame(x1),
      _733: (x0,x1) => x0.warn(x1),
      _736: x0 => globalThis.parseFloat(x0),
      _737: () => globalThis.window,
      _738: () => globalThis.Intl,
      _739: () => globalThis.Symbol,
      _742: x0 => x0.clipboard,
      _743: x0 => x0.maxTouchPoints,
      _744: x0 => x0.vendor,
      _745: x0 => x0.language,
      _746: x0 => x0.platform,
      _747: x0 => x0.userAgent,
      _748: (x0,x1) => x0.vibrate(x1),
      _749: x0 => x0.languages,
      _750: x0 => x0.documentElement,
      _751: (x0,x1) => x0.querySelector(x1),
      _754: (x0,x1) => x0.createElement(x1),
      _757: (x0,x1) => x0.createEvent(x1),
      _758: x0 => x0.activeElement,
      _761: x0 => x0.head,
      _762: x0 => x0.body,
      _764: (x0,x1) => { x0.title = x1 },
      _767: x0 => x0.visibilityState,
      _768: () => globalThis.document,
      _769: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._769(f,arguments.length,x0) }),
      _770: (x0,x1) => x0.dispatchEvent(x1),
      _778: x0 => x0.target,
      _780: x0 => x0.timeStamp,
      _781: x0 => x0.type,
      _783: (x0,x1,x2,x3) => x0.initEvent(x1,x2,x3),
      _790: x0 => x0.firstChild,
      _794: x0 => x0.parentElement,
      _796: (x0,x1) => { x0.textContent = x1 },
      _797: x0 => x0.parentNode,
      _799: x0 => x0.isConnected,
      _803: x0 => x0.firstElementChild,
      _805: x0 => x0.nextElementSibling,
      _806: x0 => x0.clientHeight,
      _807: x0 => x0.clientWidth,
      _808: x0 => x0.offsetHeight,
      _809: x0 => x0.offsetWidth,
      _810: x0 => x0.id,
      _811: (x0,x1) => { x0.id = x1 },
      _814: (x0,x1) => { x0.spellcheck = x1 },
      _815: x0 => x0.tagName,
      _816: x0 => x0.style,
      _818: (x0,x1) => x0.querySelectorAll(x1),
      _819: (x0,x1,x2) => x0.setAttribute(x1,x2),
      _820: x0 => x0.tabIndex,
      _821: (x0,x1) => { x0.tabIndex = x1 },
      _822: (x0,x1) => x0.focus(x1),
      _823: x0 => x0.scrollTop,
      _824: (x0,x1) => { x0.scrollTop = x1 },
      _825: x0 => x0.scrollLeft,
      _826: (x0,x1) => { x0.scrollLeft = x1 },
      _827: x0 => x0.classList,
      _829: (x0,x1) => { x0.className = x1 },
      _831: (x0,x1) => x0.getElementsByClassName(x1),
      _832: (x0,x1) => x0.attachShadow(x1),
      _835: x0 => x0.computedStyleMap(),
      _836: (x0,x1) => x0.get(x1),
      _842: (x0,x1) => x0.getPropertyValue(x1),
      _843: (x0,x1,x2,x3) => x0.setProperty(x1,x2,x3),
      _844: x0 => x0.offsetLeft,
      _845: x0 => x0.offsetTop,
      _846: x0 => x0.offsetParent,
      _848: (x0,x1) => { x0.name = x1 },
      _849: x0 => x0.content,
      _850: (x0,x1) => { x0.content = x1 },
      _868: (x0,x1) => { x0.nonce = x1 },
      _873: (x0,x1) => { x0.width = x1 },
      _875: (x0,x1) => { x0.height = x1 },
      _878: (x0,x1) => x0.getContext(x1),
      _940: (x0,x1) => x0.fetch(x1),
      _941: x0 => x0.status,
      _943: x0 => x0.body,
      _944: x0 => x0.arrayBuffer(),
      _947: x0 => x0.read(),
      _948: x0 => x0.value,
      _949: x0 => x0.done,
      _952: x0 => x0.x,
      _953: x0 => x0.y,
      _956: x0 => x0.top,
      _957: x0 => x0.right,
      _958: x0 => x0.bottom,
      _959: x0 => x0.left,
      _971: x0 => x0.height,
      _972: x0 => x0.width,
      _973: x0 => x0.scale,
      _974: (x0,x1) => { x0.value = x1 },
      _977: (x0,x1) => { x0.placeholder = x1 },
      _979: (x0,x1) => { x0.name = x1 },
      _980: x0 => x0.selectionDirection,
      _981: x0 => x0.selectionStart,
      _982: x0 => x0.selectionEnd,
      _985: x0 => x0.value,
      _987: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      _988: x0 => x0.readText(),
      _989: (x0,x1) => x0.writeText(x1),
      _991: x0 => x0.altKey,
      _992: x0 => x0.code,
      _993: x0 => x0.ctrlKey,
      _994: x0 => x0.key,
      _995: x0 => x0.keyCode,
      _996: x0 => x0.location,
      _997: x0 => x0.metaKey,
      _998: x0 => x0.repeat,
      _999: x0 => x0.shiftKey,
      _1000: x0 => x0.isComposing,
      _1002: x0 => x0.state,
      _1003: (x0,x1) => x0.go(x1),
      _1005: (x0,x1,x2,x3) => x0.pushState(x1,x2,x3),
      _1006: (x0,x1,x2,x3) => x0.replaceState(x1,x2,x3),
      _1007: x0 => x0.pathname,
      _1008: x0 => x0.search,
      _1009: x0 => x0.hash,
      _1013: x0 => x0.state,
      _1020: x0 => new MutationObserver(x0),
      _1021: (x0,x1,x2) => x0.observe(x1,x2),
      _1022: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1022(f,arguments.length,x0,x1) }),
      _1025: x0 => x0.attributeName,
      _1026: x0 => x0.type,
      _1027: x0 => x0.matches,
      _1028: x0 => x0.matches,
      _1032: x0 => x0.relatedTarget,
      _1034: x0 => x0.clientX,
      _1035: x0 => x0.clientY,
      _1036: x0 => x0.offsetX,
      _1037: x0 => x0.offsetY,
      _1040: x0 => x0.button,
      _1041: x0 => x0.buttons,
      _1042: x0 => x0.ctrlKey,
      _1046: x0 => x0.pointerId,
      _1047: x0 => x0.pointerType,
      _1048: x0 => x0.pressure,
      _1049: x0 => x0.tiltX,
      _1050: x0 => x0.tiltY,
      _1051: x0 => x0.getCoalescedEvents(),
      _1054: x0 => x0.deltaX,
      _1055: x0 => x0.deltaY,
      _1056: x0 => x0.wheelDeltaX,
      _1057: x0 => x0.wheelDeltaY,
      _1058: x0 => x0.deltaMode,
      _1065: x0 => x0.changedTouches,
      _1068: x0 => x0.clientX,
      _1069: x0 => x0.clientY,
      _1072: x0 => x0.data,
      _1075: (x0,x1) => { x0.disabled = x1 },
      _1077: (x0,x1) => { x0.type = x1 },
      _1078: (x0,x1) => { x0.max = x1 },
      _1079: (x0,x1) => { x0.min = x1 },
      _1080: x0 => x0.value,
      _1081: (x0,x1) => { x0.value = x1 },
      _1082: x0 => x0.disabled,
      _1083: (x0,x1) => { x0.disabled = x1 },
      _1085: (x0,x1) => { x0.placeholder = x1 },
      _1087: (x0,x1) => { x0.name = x1 },
      _1089: (x0,x1) => { x0.autocomplete = x1 },
      _1090: x0 => x0.selectionDirection,
      _1092: x0 => x0.selectionStart,
      _1093: x0 => x0.selectionEnd,
      _1096: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      _1097: (x0,x1) => x0.add(x1),
      _1100: (x0,x1) => { x0.noValidate = x1 },
      _1101: (x0,x1) => { x0.method = x1 },
      _1102: (x0,x1) => { x0.action = x1 },
      _1128: x0 => x0.orientation,
      _1129: x0 => x0.width,
      _1130: x0 => x0.height,
      _1131: (x0,x1) => x0.lock(x1),
      _1150: x0 => new ResizeObserver(x0),
      _1153: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1153(f,arguments.length,x0,x1) }),
      _1161: x0 => x0.length,
      _1162: x0 => x0.iterator,
      _1163: x0 => x0.Segmenter,
      _1164: x0 => x0.v8BreakIterator,
      _1165: (x0,x1) => new Intl.Segmenter(x0,x1),
      _1166: x0 => x0.done,
      _1167: x0 => x0.value,
      _1168: x0 => x0.index,
      _1172: (x0,x1) => new Intl.v8BreakIterator(x0,x1),
      _1173: (x0,x1) => x0.adoptText(x1),
      _1174: x0 => x0.first(),
      _1175: x0 => x0.next(),
      _1176: x0 => x0.current(),
      _1182: x0 => x0.hostElement,
      _1183: x0 => x0.viewConstraints,
      _1186: x0 => x0.maxHeight,
      _1187: x0 => x0.maxWidth,
      _1188: x0 => x0.minHeight,
      _1189: x0 => x0.minWidth,
      _1190: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1190(f,arguments.length,x0) }),
      _1191: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1191(f,arguments.length,x0) }),
      _1192: (x0,x1) => ({addView: x0,removeView: x1}),
      _1193: x0 => x0.loader,
      _1194: () => globalThis._flutter,
      _1195: (x0,x1) => x0.didCreateEngineInitializer(x1),
      _1196: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1196(f,arguments.length,x0) }),
      _1197: f => finalizeWrapper(f, function() { return dartInstance.exports._1197(f,arguments.length) }),
      _1198: (x0,x1) => ({initializeEngine: x0,autoStart: x1}),
      _1199: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1199(f,arguments.length,x0) }),
      _1200: x0 => ({runApp: x0}),
      _1201: f => finalizeWrapper(f, function(x0,x1) { return dartInstance.exports._1201(f,arguments.length,x0,x1) }),
      _1202: x0 => x0.length,
      _1277: x0 => x0.createReader(),
      _1278: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1278(f,arguments.length,x0) }),
      _1279: (x0,x1) => x0.readEntries(x1),
      _1280: () => new Blob(),
      _1281: (x0,x1,x2,x3) => x0.slice(x1,x2,x3),
      _1282: x0 => globalThis.URL.createObjectURL(x0),
      _1283: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1283(f,arguments.length,x0) }),
      _1284: (x0,x1) => x0.file(x1),
      _1285: x0 => x0.preventDefault(),
      _1286: x0 => x0.webkitGetAsEntry(),
      _1287: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1287(f,arguments.length,x0) }),
      _1288: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1288(f,arguments.length,x0) }),
      _1289: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1289(f,arguments.length,x0) }),
      _1290: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1290(f,arguments.length,x0) }),
      _1299: (x0,x1) => x0.querySelector(x1),
      _1300: (x0,x1) => x0.createElement(x1),
      _1301: x0 => ({type: x0}),
      _1302: (x0,x1) => new Blob(x0,x1),
      _1303: (x0,x1) => x0.item(x1),
      _1304: () => new FileReader(),
      _1306: (x0,x1) => x0.readAsArrayBuffer(x1),
      _1307: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1307(f,arguments.length,x0) }),
      _1308: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      _1309: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1309(f,arguments.length,x0) }),
      _1310: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _1311: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1311(f,arguments.length,x0) }),
      _1312: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1312(f,arguments.length,x0) }),
      _1313: (x0,x1) => x0.removeChild(x1),
      _1314: x0 => x0.click(),
      _1318: Date.now,
      _1320: s => new Date(s * 1000).getTimezoneOffset() * 60,
      _1321: s => {
        if (!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(s)) {
          return NaN;
        }
        return parseFloat(s);
      },
      _1322: () => {
        let stackString = new Error().stack.toString();
        let frames = stackString.split('\n');
        let drop = 2;
        if (frames[0] === 'Error') {
            drop += 1;
        }
        return frames.slice(drop).join('\n');
      },
      _1323: () => typeof dartUseDateNowForTicks !== "undefined",
      _1324: () => 1000 * performance.now(),
      _1325: () => Date.now(),
      _1327: () => {
        return typeof process != "undefined" &&
               Object.prototype.toString.call(process) == "[object process]" &&
               process.platform == "win32"
      },
      _1328: () => new WeakMap(),
      _1329: (map, o) => map.get(o),
      _1330: (map, o, v) => map.set(o, v),
      _1331: x0 => new WeakRef(x0),
      _1332: x0 => x0.deref(),
      _1339: () => globalThis.WeakRef,
      _1343: s => JSON.stringify(s),
      _1344: s => printToConsole(s),
      _1345: (o, p, r) => o.replaceAll(p, () => r),
      _1346: (o, p, r) => o.replace(p, () => r),
      _1347: Function.prototype.call.bind(String.prototype.toLowerCase),
      _1348: s => s.toUpperCase(),
      _1349: s => s.trim(),
      _1350: s => s.trimLeft(),
      _1351: s => s.trimRight(),
      _1352: (string, times) => string.repeat(times),
      _1353: Function.prototype.call.bind(String.prototype.indexOf),
      _1354: (s, p, i) => s.lastIndexOf(p, i),
      _1355: (string, token) => string.split(token),
      _1356: Object.is,
      _1357: o => o instanceof Array,
      _1358: (a, i) => a.push(i),
      _1361: (a, l) => a.length = l,
      _1362: a => a.pop(),
      _1363: (a, i) => a.splice(i, 1),
      _1364: (a, s) => a.join(s),
      _1365: (a, s, e) => a.slice(s, e),
      _1368: a => a.length,
      _1370: (a, i) => a[i],
      _1371: (a, i, v) => a[i] = v,
      _1373: o => {
        if (o instanceof ArrayBuffer) return 0;
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
          return 1;
        }
        return 2;
      },
      _1374: (o, offsetInBytes, lengthInBytes) => {
        var dst = new ArrayBuffer(lengthInBytes);
        new Uint8Array(dst).set(new Uint8Array(o, offsetInBytes, lengthInBytes));
        return new DataView(dst);
      },
      _1376: o => o instanceof Uint8Array,
      _1377: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
      _1378: o => o instanceof Int8Array,
      _1379: (o, start, length) => new Int8Array(o.buffer, o.byteOffset + start, length),
      _1380: o => o instanceof Uint8ClampedArray,
      _1381: (o, start, length) => new Uint8ClampedArray(o.buffer, o.byteOffset + start, length),
      _1382: o => o instanceof Uint16Array,
      _1383: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
      _1384: o => o instanceof Int16Array,
      _1385: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
      _1386: o => o instanceof Uint32Array,
      _1387: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
      _1388: o => o instanceof Int32Array,
      _1389: (o, start, length) => new Int32Array(o.buffer, o.byteOffset + start, length),
      _1391: (o, start, length) => new BigInt64Array(o.buffer, o.byteOffset + start, length),
      _1392: o => o instanceof Float32Array,
      _1393: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
      _1394: o => o instanceof Float64Array,
      _1395: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
      _1396: (t, s) => t.set(s),
      _1398: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
      _1400: o => o.buffer,
      _1401: o => o.byteOffset,
      _1402: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
      _1403: (b, o) => new DataView(b, o),
      _1404: (b, o, l) => new DataView(b, o, l),
      _1405: Function.prototype.call.bind(DataView.prototype.getUint8),
      _1406: Function.prototype.call.bind(DataView.prototype.setUint8),
      _1407: Function.prototype.call.bind(DataView.prototype.getInt8),
      _1408: Function.prototype.call.bind(DataView.prototype.setInt8),
      _1409: Function.prototype.call.bind(DataView.prototype.getUint16),
      _1410: Function.prototype.call.bind(DataView.prototype.setUint16),
      _1411: Function.prototype.call.bind(DataView.prototype.getInt16),
      _1412: Function.prototype.call.bind(DataView.prototype.setInt16),
      _1413: Function.prototype.call.bind(DataView.prototype.getUint32),
      _1414: Function.prototype.call.bind(DataView.prototype.setUint32),
      _1415: Function.prototype.call.bind(DataView.prototype.getInt32),
      _1416: Function.prototype.call.bind(DataView.prototype.setInt32),
      _1419: Function.prototype.call.bind(DataView.prototype.getBigInt64),
      _1420: Function.prototype.call.bind(DataView.prototype.setBigInt64),
      _1421: Function.prototype.call.bind(DataView.prototype.getFloat32),
      _1422: Function.prototype.call.bind(DataView.prototype.setFloat32),
      _1423: Function.prototype.call.bind(DataView.prototype.getFloat64),
      _1424: Function.prototype.call.bind(DataView.prototype.setFloat64),
      _1437: (ms, c) =>
      setTimeout(() => dartInstance.exports.$invokeCallback(c),ms),
      _1438: (handle) => clearTimeout(handle),
      _1439: (ms, c) =>
      setInterval(() => dartInstance.exports.$invokeCallback(c), ms),
      _1440: (handle) => clearInterval(handle),
      _1441: (c) =>
      queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
      _1442: () => Date.now(),
      _1447: o => Object.keys(o),
      _1448: () => new XMLHttpRequest(),
      _1449: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      _1450: x0 => x0.send(),
      _1456: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1456(f,arguments.length,x0) }),
      _1457: f => finalizeWrapper(f, function(x0) { return dartInstance.exports._1457(f,arguments.length,x0) }),
      _1458: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      _1459: (x0,x1,x2,x3) => x0.removeEventListener(x1,x2,x3),
      _1476: (s, m) => {
        try {
          return new RegExp(s, m);
        } catch (e) {
          return String(e);
        }
      },
      _1477: (x0,x1) => x0.exec(x1),
      _1478: (x0,x1) => x0.test(x1),
      _1479: x0 => x0.pop(),
      _1481: o => o === undefined,
      _1483: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
      _1485: o => {
        const proto = Object.getPrototypeOf(o);
        return proto === Object.prototype || proto === null;
      },
      _1486: o => o instanceof RegExp,
      _1487: (l, r) => l === r,
      _1488: o => o,
      _1489: o => o,
      _1490: o => o,
      _1491: b => !!b,
      _1492: o => o.length,
      _1494: (o, i) => o[i],
      _1495: f => f.dartFunction,
      _1496: () => ({}),
      _1497: () => [],
      _1499: () => globalThis,
      _1500: (constructor, args) => {
        const factoryFunction = constructor.bind.apply(
            constructor, [null, ...args]);
        return new factoryFunction();
      },
      _1502: (o, p) => o[p],
      _1503: (o, p, v) => o[p] = v,
      _1504: (o, m, a) => o[m].apply(o, a),
      _1506: o => String(o),
      _1507: (p, s, f) => p.then(s, (e) => f(e, e === undefined)),
      _1508: o => {
        if (o === undefined) return 1;
        var type = typeof o;
        if (type === 'boolean') return 2;
        if (type === 'number') return 3;
        if (type === 'string') return 4;
        if (o instanceof Array) return 5;
        if (ArrayBuffer.isView(o)) {
          if (o instanceof Int8Array) return 6;
          if (o instanceof Uint8Array) return 7;
          if (o instanceof Uint8ClampedArray) return 8;
          if (o instanceof Int16Array) return 9;
          if (o instanceof Uint16Array) return 10;
          if (o instanceof Int32Array) return 11;
          if (o instanceof Uint32Array) return 12;
          if (o instanceof Float32Array) return 13;
          if (o instanceof Float64Array) return 14;
          if (o instanceof DataView) return 15;
        }
        if (o instanceof ArrayBuffer) return 16;
        // Feature check for `SharedArrayBuffer` before doing a type-check.
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
            return 17;
        }
        return 18;
      },
      _1509: o => [o],
      _1510: (o0, o1) => [o0, o1],
      _1511: (o0, o1, o2) => [o0, o1, o2],
      _1512: (o0, o1, o2, o3) => [o0, o1, o2, o3],
      _1513: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI8ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _1514: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI8ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _1517: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _1518: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _1519: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _1520: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _1521: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF64ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _1522: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF64ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _1523: x0 => new ArrayBuffer(x0),
      _1524: s => {
        if (/[[\]{}()*+?.\\^$|]/.test(s)) {
            s = s.replace(/[[\]{}()*+?.\\^$|]/g, '\\$&');
        }
        return s;
      },
      _1526: x0 => x0.index,
      _1528: x0 => x0.flags,
      _1529: x0 => x0.multiline,
      _1530: x0 => x0.ignoreCase,
      _1531: x0 => x0.unicode,
      _1532: x0 => x0.dotAll,
      _1533: (x0,x1) => { x0.lastIndex = x1 },
      _1534: (o, p) => p in o,
      _1535: (o, p) => o[p],
      _1538: x0 => x0.random(),
      _1541: () => globalThis.Math,
      _1542: Function.prototype.call.bind(Number.prototype.toString),
      _1543: Function.prototype.call.bind(BigInt.prototype.toString),
      _1544: Function.prototype.call.bind(Number.prototype.toString),
      _1545: (d, digits) => d.toFixed(digits),
      _1640: (x0,x1) => { x0.responseType = x1 },
      _1641: x0 => x0.response,
      _1701: (x0,x1) => { x0.draggable = x1 },
      _1717: x0 => x0.style,
      _2646: (x0,x1) => { x0.accept = x1 },
      _2660: x0 => x0.files,
      _2686: (x0,x1) => { x0.multiple = x1 },
      _2704: (x0,x1) => { x0.type = x1 },
      _3405: x0 => x0.items,
      _3408: (x0,x1) => x0[x1],
      _3412: x0 => x0.length,
      _3418: x0 => x0.dataTransfer,
      _3422: () => globalThis.window,
      _3485: x0 => x0.navigator,
      _3556: (x0,x1) => { x0.ondragenter = x1 },
      _3558: (x0,x1) => { x0.ondragleave = x1 },
      _3560: (x0,x1) => { x0.ondragover = x1 },
      _3564: (x0,x1) => { x0.ondrop = x1 },
      _3875: x0 => x0.vendor,
      _5988: x0 => x0.type,
      _6091: x0 => x0.firstChild,
      _6102: () => globalThis.document,
      _6522: (x0,x1) => { x0.id = x1 },
      _6549: x0 => x0.children,
      _6855: x0 => x0.clientX,
      _6856: x0 => x0.clientY,
      _8051: x0 => x0.size,
      _8052: x0 => x0.type,
      _8059: x0 => x0.name,
      _8060: x0 => x0.lastModified,
      _8065: x0 => x0.length,
      _8070: x0 => x0.result,
      _10980: (x0,x1) => { x0.display = x1 },
      _12887: x0 => x0.isDirectory,
      _12888: x0 => x0.name,
      _12889: x0 => x0.fullPath,

    };

    const baseImports = {
      dart2wasm: dart2wasm,
      Math: Math,
      Date: Date,
      Object: Object,
      Array: Array,
      Reflect: Reflect,
      s: [
        "[#*0-9]️?⃣|[©®‼⁉™ℹ↔-↙↩↪⌚⌛⌨⏏⏭-⏯⏱⏲⏸-⏺Ⓜ▪▫▶◀◻◼◾☀-☄☎☑☔☕☘☠☢☣☦☪☮☯☸-☺♀♂♈-♓♟♠♣♥♦♨♻♾♿⚒⚔-⚗⚙⚛⚜⚠⚧⚪⚰⚱⚽⚾⛄⛈⛏⛑⛓⛩⛰-⛵⛷⛸⛺✂✈✉✏✒✔✖✝✡✳✴❄❇❗❣➡⤴⤵⬅-⬇⬛⬜⭕〰〽㊗㊙]️?|[☝✌✍](?:️|\ud83c[\udffb-\udfff])?|[✊✋](?:\ud83c[\udffb-\udfff])?|[⏩-⏬⏰⏳◽⚓⚡⚫⛅⛎⛔⛪⛽✅✨❌❎❓-❕➕-➗➰➿⭐]|⛹(?:️|\ud83c[\udffb-\udfff])?(?:‍[♀♂]️?)?|❤️?(?:‍(?:🔥|🩹))?|\ud83c(?:[\udc04\udd70\udd71\udd7e\udd7f\ude02\ude37\udf21\udf24-\udf2c\udf36\udf7d\udf96\udf97\udf99-\udf9b\udf9e\udf9f\udfcd\udfce\udfd4-\udfdf\udff5\udff7]️?|[\udf85\udfc2\udfc7](?:\ud83c[\udffb-\udfff])?|[\udfc3\udfc4\udfca](?:\ud83c[\udffb-\udfff])?(?:‍[♀♂]️?)?|[\udfcb\udfcc](?:️|\ud83c[\udffb-\udfff])?(?:‍[♀♂]️?)?|[\udccf\udd8e\udd91-\udd9a\ude01\ude1a\ude2f\ude32-\ude36\ude38-\ude3a\ude50\ude51\udf00-\udf20\udf2d-\udf35\udf37-\udf7c\udf7e-\udf84\udf86-\udf93\udfa0-\udfc1\udfc5\udfc6\udfc8\udfc9\udfcf-\udfd3\udfe0-\udff0\udff8-\udfff]|\udde6\ud83c[\udde8-\uddec\uddee\uddf1\uddf2\uddf4\uddf6-\uddfa\uddfc\uddfd\uddff]|\udde7\ud83c[\udde6\udde7\udde9-\uddef\uddf1-\uddf4\uddf6-\uddf9\uddfb\uddfc\uddfe\uddff]|\udde8\ud83c[\udde6\udde8\udde9\uddeb-\uddee\uddf0-\uddf5\uddf7\uddfa-\uddff]|\udde9\ud83c[\uddea\uddec\uddef\uddf0\uddf2\uddf4\uddff]|\uddea\ud83c[\udde6\udde8\uddea\uddec\udded\uddf7-\uddfa]|\uddeb\ud83c[\uddee-\uddf0\uddf2\uddf4\uddf7]|\uddec\ud83c[\udde6\udde7\udde9-\uddee\uddf1-\uddf3\uddf5-\uddfa\uddfc\uddfe]|\udded\ud83c[\uddf0\uddf2\uddf3\uddf7\uddf9\uddfa]|\uddee\ud83c[\udde8-\uddea\uddf1-\uddf4\uddf6-\uddf9]|\uddef\ud83c[\uddea\uddf2\uddf4\uddf5]|\uddf0\ud83c[\uddea\uddec-\uddee\uddf2\uddf3\uddf5\uddf7\uddfc\uddfe\uddff]|\uddf1\ud83c[\udde6-\udde8\uddee\uddf0\uddf7-\uddfb\uddfe]|\uddf2\ud83c[\udde6\udde8-\udded\uddf0-\uddff]|\uddf3\ud83c[\udde6\udde8\uddea-\uddec\uddee\uddf1\uddf4\uddf5\uddf7\uddfa\uddff]|\uddf4🇲|\uddf5\ud83c[\udde6\uddea-\udded\uddf0-\uddf3\uddf7-\uddf9\uddfc\uddfe]|\uddf6🇦|\uddf7\ud83c[\uddea\uddf4\uddf8\uddfa\uddfc]|\uddf8\ud83c[\udde6-\uddea\uddec-\uddf4\uddf7-\uddf9\uddfb\uddfd-\uddff]|\uddf9\ud83c[\udde6\udde8\udde9\uddeb-\udded\uddef-\uddf4\uddf7\uddf9\uddfb\uddfc\uddff]|\uddfa\ud83c[\udde6\uddec\uddf2\uddf3\uddf8\uddfe\uddff]|\uddfb\ud83c[\udde6\udde8\uddea\uddec\uddee\uddf3\uddfa]|\uddfc\ud83c[\uddeb\uddf8]|\uddfd🇰|\uddfe\ud83c[\uddea\uddf9]|\uddff\ud83c[\udde6\uddf2\uddfc]|\udff3️?(?:‍(?:⚧️?|🌈))?|\udff4(?:‍☠️?|󠁧󠁢\udb40(?:\udc65󠁮󠁧|\udc73󠁣󠁴|\udc77󠁬󠁳)󠁿)?)|\ud83d(?:[\udc08\udc26](?:‍⬛)?|[\udc3f\udcfd\udd49\udd4a\udd6f\udd70\udd73\udd76-\udd79\udd87\udd8a-\udd8d\udda5\udda8\uddb1\uddb2\uddbc\uddc2-\uddc4\uddd1-\uddd3\udddc-\uddde\udde1\udde3\udde8\uddef\uddf3\uddfa\udecb\udecd-\udecf\udee0-\udee5\udee9\udef0\udef3]️?|[\udc42\udc43\udc46-\udc50\udc66\udc67\udc6b-\udc6d\udc72\udc74-\udc76\udc78\udc7c\udc83\udc85\udc8f\udc91\udcaa\udd7a\udd95\udd96\ude4c\ude4f\udec0\udecc](?:\ud83c[\udffb-\udfff])?|[\udc6e\udc70\udc71\udc73\udc77\udc81\udc82\udc86\udc87\ude45-\ude47\ude4b\ude4d\ude4e\udea3\udeb4-\udeb6](?:\ud83c[\udffb-\udfff])?(?:‍[♀♂]️?)?|[\udd74\udd90](?:️|\ud83c[\udffb-\udfff])?|[\udc00-\udc07\udc09-\udc14\udc16-\udc25\udc27-\udc3a\udc3c-\udc3e\udc40\udc44\udc45\udc51-\udc65\udc6a\udc79-\udc7b\udc7d-\udc80\udc84\udc88-\udc8e\udc90\udc92-\udca9\udcab-\udcfc\udcff-\udd3d\udd4b-\udd4e\udd50-\udd67\udda4\uddfb-\ude2d\ude2f-\ude34\ude37-\ude44\ude48-\ude4a\ude80-\udea2\udea4-\udeb3\udeb7-\udebf\udec1-\udec5\uded0-\uded2\uded5-\uded7\udedc-\udedf\udeeb\udeec\udef4-\udefc\udfe0-\udfeb\udff0]|\udc15(?:‍🦺)?|\udc3b(?:‍❄️?)?|\udc41️?(?:‍🗨️?)?|\udc68(?:‍(?:[⚕⚖✈]️?|❤️?‍\ud83d(?:\udc8b‍\ud83d)?\udc68|\ud83c[\udf3e\udf73\udf7c\udf93\udfa4\udfa8\udfeb\udfed]|\ud83d(?:[\udc68\udc69]‍\ud83d(?:\udc66(?:‍👦)?|\udc67(?:‍\ud83d[\udc66\udc67])?)|[\udcbb\udcbc\udd27\udd2c\ude80\ude92]|\udc66(?:‍👦)?|\udc67(?:‍\ud83d[\udc66\udc67])?)|\ud83e[\uddaf-\uddb3\uddbc\uddbd])|\ud83c(?:\udffb(?:‍(?:[⚕⚖✈]️?|❤️?‍\ud83d(?:\udc8b‍\ud83d)?\udc68\ud83c[\udffb-\udfff]|\ud83c[\udf3e\udf73\udf7c\udf93\udfa4\udfa8\udfeb\udfed]|\ud83d[\udcbb\udcbc\udd27\udd2c\ude80\ude92]|\ud83e(?:[\uddaf-\uddb3\uddbc\uddbd]|\udd1d‍👨\ud83c[\udffc-\udfff])))?|\udffc(?:‍(?:[⚕⚖✈]️?|❤️?‍\ud83d(?:\udc8b‍\ud83d)?\udc68\ud83c[\udffb-\udfff]|\ud83c[\udf3e\udf73\udf7c\udf93\udfa4\udfa8\udfeb\udfed]|\ud83d[\udcbb\udcbc\udd27\udd2c\ude80\ude92]|\ud83e(?:[\uddaf-\uddb3\uddbc\uddbd]|\udd1d‍👨\ud83c[\udffb\udffd-\udfff])))?|\udffd(?:‍(?:[⚕⚖✈]️?|❤️?‍\ud83d(?:\udc8b‍\ud83d)?\udc68\ud83c[\udffb-\udfff]|\ud83c[\udf3e\udf73\udf7c\udf93\udfa4\udfa8\udfeb\udfed]|\ud83d[\udcbb\udcbc\udd27\udd2c\ude80\ude92]|\ud83e(?:[\uddaf-\uddb3\uddbc\uddbd]|\udd1d‍👨\ud83c[\udffb\udffc\udffe\udfff])))?|\udffe(?:‍(?:[⚕⚖✈]️?|❤️?‍\ud83d(?:\udc8b‍\ud83d)?\udc68\ud83c[\udffb-\udfff]|\ud83c[\udf3e\udf73\udf7c\udf93\udfa4\udfa8\udfeb\udfed]|\ud83d[\udcbb\udcbc\udd27\udd2c\ude80\ude92]|\ud83e(?:[\uddaf-\uddb3\uddbc\uddbd]|\udd1d‍👨\ud83c[\udffb-\udffd\udfff])))?|\udfff(?:‍(?:[⚕⚖✈]️?|❤️?‍\ud83d(?:\udc8b‍\ud83d)?\udc68\ud83c[\udffb-\udfff]|\ud83c[\udf3e\udf73\udf7c\udf93\udfa4\udfa8\udfeb\udfed]|\ud83d[\udcbb\udcbc\udd27\udd2c\ude80\ude92]|\ud83e(?:[\uddaf-\uddb3\uddbc\uddbd]|\udd1d‍👨\ud83c[\udffb-\udffe])))?))?|\udc69(?:‍(?:[⚕⚖✈]️?|❤️?‍\ud83d(?:\udc8b‍\ud83d)?[\udc68\udc69]|\ud83c[\udf3e\udf73\udf7c\udf93\udfa4\udfa8\udfeb\udfed]|\ud83d(?:[\udcbb\udcbc\udd27\udd2c\ude80\ude92]|\udc66(?:‍👦)?|\udc67(?:‍\ud83d[\udc66\udc67])?|\udc69‍\ud83d(?:\udc66(?:‍👦)?|\udc67(?:‍\ud83d[\udc66\udc67])?))|\ud83e[\uddaf-\uddb3\uddbc\uddbd])|\ud83c(?:\udffb(?:‍(?:[⚕⚖✈]️?|❤️?‍\ud83d(?:[\udc68\udc69]|\udc8b‍\ud83d[\udc68\udc69])\ud83c[\udffb-\udfff]|\ud83c[\udf3e\udf73\udf7c\udf93\udfa4\udfa8\udfeb\udfed]|\ud83d[\udcbb\udcbc\udd27\udd2c\ude80\ude92]|\ud83e(?:[\uddaf-\uddb3\uddbc\uddbd]|\udd1d‍\ud83d[\udc68\udc69]\ud83c[\udffc-\udfff])))?|\udffc(?:‍(?:[⚕⚖✈]️?|❤️?‍\ud83d(?:[\udc68\udc69]|\udc8b‍\ud83d[\udc68\udc69])\ud83c[\udffb-\udfff]|\ud83c[\udf3e\udf73\udf7c\udf93\udfa4\udfa8\udfeb\udfed]|\ud83d[\udcbb\udcbc\udd27\udd2c\ude80\ude92]|\ud83e(?:[\uddaf-\uddb3\uddbc\uddbd]|\udd1d‍\ud83d[\udc68\udc69]\ud83c[\udffb\udffd-\udfff])))?|\udffd(?:‍(?:[⚕⚖✈]️?|❤️?‍\ud83d(?:[\udc68\udc69]|\udc8b‍\ud83d[\udc68\udc69])\ud83c[\udffb-\udfff]|\ud83c[\udf3e\udf73\udf7c\udf93\udfa4\udfa8\udfeb\udfed]|\ud83d[\udcbb\udcbc\udd27\udd2c\ude80\ude92]|\ud83e(?:[\uddaf-\uddb3\uddbc\uddbd]|\udd1d‍\ud83d[\udc68\udc69]\ud83c[\udffb\udffc\udffe\udfff])))?|\udffe(?:‍(?:[⚕⚖✈]️?|❤️?‍\ud83d(?:[\udc68\udc69]|\udc8b‍\ud83d[\udc68\udc69])\ud83c[\udffb-\udfff]|\ud83c[\udf3e\udf73\udf7c\udf93\udfa4\udfa8\udfeb\udfed]|\ud83d[\udcbb\udcbc\udd27\udd2c\ude80\ude92]|\ud83e(?:[\uddaf-\uddb3\uddbc\uddbd]|\udd1d‍\ud83d[\udc68\udc69]\ud83c[\udffb-\udffd\udfff])))?|\udfff(?:‍(?:[⚕⚖✈]️?|❤️?‍\ud83d(?:[\udc68\udc69]|\udc8b‍\ud83d[\udc68\udc69])\ud83c[\udffb-\udfff]|\ud83c[\udf3e\udf73\udf7c\udf93\udfa4\udfa8\udfeb\udfed]|\ud83d[\udcbb\udcbc\udd27\udd2c\ude80\ude92]|\ud83e(?:[\uddaf-\uddb3\uddbc\uddbd]|\udd1d‍\ud83d[\udc68\udc69]\ud83c[\udffb-\udffe])))?))?|\udc6f(?:‍[♀♂]️?)?|\udd75(?:️|\ud83c[\udffb-\udfff])?(?:‍[♀♂]️?)?|\ude2e(?:‍💨)?|\ude35(?:‍💫)?|\ude36(?:‍🌫️?)?)|\ud83e(?:[\udd0c\udd0f\udd18-\udd1f\udd30-\udd34\udd36\udd77\uddb5\uddb6\uddbb\uddd2\uddd3\uddd5\udec3-\udec5\udef0\udef2-\udef8](?:\ud83c[\udffb-\udfff])?|[\udd26\udd35\udd37-\udd39\udd3d\udd3e\uddb8\uddb9\uddcd-\uddcf\uddd4\uddd6-\udddd](?:\ud83c[\udffb-\udfff])?(?:‍[♀♂]️?)?|[\uddde\udddf](?:‍[♀♂]️?)?|[\udd0d\udd0e\udd10-\udd17\udd20-\udd25\udd27-\udd2f\udd3a\udd3f-\udd45\udd47-\udd76\udd78-\uddb4\uddb7\uddba\uddbc-\uddcc\uddd0\udde0-\uddff\ude70-\ude7c\ude80-\ude88\ude90-\udebd\udebf-\udec2\udece-\udedb\udee0-\udee8]|\udd3c(?:‍[♀♂]️?|\ud83c[\udffb-\udfff])?|\uddd1(?:‍(?:[⚕⚖✈]️?|\ud83c[\udf3e\udf73\udf7c\udf84\udf93\udfa4\udfa8\udfeb\udfed]|\ud83d[\udcbb\udcbc\udd27\udd2c\ude80\ude92]|\ud83e(?:[\uddaf-\uddb3\uddbc\uddbd]|\udd1d‍🧑))|\ud83c(?:\udffb(?:‍(?:[⚕⚖✈]️?|❤️?‍(?:💋‍)?🧑\ud83c[\udffc-\udfff]|\ud83c[\udf3e\udf73\udf7c\udf84\udf93\udfa4\udfa8\udfeb\udfed]|\ud83d[\udcbb\udcbc\udd27\udd2c\ude80\ude92]|\ud83e(?:[\uddaf-\uddb3\uddbc\uddbd]|\udd1d‍🧑\ud83c[\udffb-\udfff])))?|\udffc(?:‍(?:[⚕⚖✈]️?|❤️?‍(?:💋‍)?🧑\ud83c[\udffb\udffd-\udfff]|\ud83c[\udf3e\udf73\udf7c\udf84\udf93\udfa4\udfa8\udfeb\udfed]|\ud83d[\udcbb\udcbc\udd27\udd2c\ude80\ude92]|\ud83e(?:[\uddaf-\uddb3\uddbc\uddbd]|\udd1d‍🧑\ud83c[\udffb-\udfff])))?|\udffd(?:‍(?:[⚕⚖✈]️?|❤️?‍(?:💋‍)?🧑\ud83c[\udffb\udffc\udffe\udfff]|\ud83c[\udf3e\udf73\udf7c\udf84\udf93\udfa4\udfa8\udfeb\udfed]|\ud83d[\udcbb\udcbc\udd27\udd2c\ude80\ude92]|\ud83e(?:[\uddaf-\uddb3\uddbc\uddbd]|\udd1d‍🧑\ud83c[\udffb-\udfff])))?|\udffe(?:‍(?:[⚕⚖✈]️?|❤️?‍(?:💋‍)?🧑\ud83c[\udffb-\udffd\udfff]|\ud83c[\udf3e\udf73\udf7c\udf84\udf93\udfa4\udfa8\udfeb\udfed]|\ud83d[\udcbb\udcbc\udd27\udd2c\ude80\ude92]|\ud83e(?:[\uddaf-\uddb3\uddbc\uddbd]|\udd1d‍🧑\ud83c[\udffb-\udfff])))?|\udfff(?:‍(?:[⚕⚖✈]️?|❤️?‍(?:💋‍)?🧑\ud83c[\udffb-\udffe]|\ud83c[\udf3e\udf73\udf7c\udf84\udf93\udfa4\udfa8\udfeb\udfed]|\ud83d[\udcbb\udcbc\udd27\udd2c\ude80\ude92]|\ud83e(?:[\uddaf-\uddb3\uddbc\uddbd]|\udd1d‍🧑\ud83c[\udffb-\udfff])))?))?|\udef1(?:\ud83c(?:\udffb(?:‍🫲\ud83c[\udffc-\udfff])?|\udffc(?:‍🫲\ud83c[\udffb\udffd-\udfff])?|\udffd(?:‍🫲\ud83c[\udffb\udffc\udffe\udfff])?|\udffe(?:‍🫲\ud83c[\udffb-\udffd\udfff])?|\udfff(?:‍🫲\ud83c[\udffb-\udffe])?))?)",
      ],
      S: new Proxy({}, { get(_, prop) { return prop; } }),

    };

    const jsStringPolyfill = {
      "charCodeAt": (s, i) => s.charCodeAt(i),
      "compare": (s1, s2) => {
        if (s1 < s2) return -1;
        if (s1 > s2) return 1;
        return 0;
      },
      "concat": (s1, s2) => s1 + s2,
      "equals": (s1, s2) => s1 === s2,
      "fromCharCode": (i) => String.fromCharCode(i),
      "length": (s) => s.length,
      "substring": (s, a, b) => s.substring(a, b),
      "fromCharCodeArray": (a, start, end) => {
        if (end <= start) return '';

        const read = dartInstance.exports.$wasmI16ArrayGet;
        let result = '';
        let index = start;
        const chunkLength = Math.min(end - index, 500);
        let array = new Array(chunkLength);
        while (index < end) {
          const newChunkLength = Math.min(end - index, 500);
          for (let i = 0; i < newChunkLength; i++) {
            array[i] = read(a, index++);
          }
          if (newChunkLength < chunkLength) {
            array = array.slice(0, newChunkLength);
          }
          result += String.fromCharCode(...array);
        }
        return result;
      },
      "intoCharCodeArray": (s, a, start) => {
        if (s === '') return 0;

        const write = dartInstance.exports.$wasmI16ArraySet;
        for (var i = 0; i < s.length; ++i) {
          write(a, start++, s.charCodeAt(i));
        }
        return s.length;
      },
      "test": (s) => typeof s == "string",
    };


    

    dartInstance = await WebAssembly.instantiate(this.module, {
      ...baseImports,
      ...additionalImports,
      
      "wasm:js-string": jsStringPolyfill,
    });

    return new InstantiatedApp(this, dartInstance);
  }
}

class InstantiatedApp {
  constructor(compiledApp, instantiatedModule) {
    this.compiledApp = compiledApp;
    this.instantiatedModule = instantiatedModule;
  }

  // Call the main function with the given arguments.
  invokeMain(...args) {
    this.instantiatedModule.exports.$invokeMain(args);
  }
}

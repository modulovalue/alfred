(function dartProgram(){function copyProperties(a,b){var t=Object.keys(a)
for(var s=0;s<t.length;s++){var r=t[s]
b[r]=a[r]}}function mixinProperties(a,b){var t=Object.keys(a)
for(var s=0;s<t.length;s++){var r=t[s]
if(!b.hasOwnProperty(r))b[r]=a[r]}}var z=function(){var t=function(){}
t.prototype={p:{}}
var s=new t()
if(!(s.__proto__&&s.__proto__.p===t.prototype.p))return false
try{if(typeof navigator!="undefined"&&typeof navigator.userAgent=="string"&&navigator.userAgent.indexOf("Chrome/")>=0)return true
if(typeof version=="function"&&version.length==0){var r=version()
if(/^\d+\.\d+\.\d+\.\d+$/.test(r))return true}}catch(q){}return false}()
function setFunctionNamesIfNecessary(a){function t(){};if(typeof t.name=="string")return
for(var t=0;t<a.length;t++){var s=a[t]
var r=Object.keys(s)
for(var q=0;q<r.length;q++){var p=r[q]
var o=s[p]
if(typeof o=="function")o.name=p}}}function inherit(a,b){a.prototype.constructor=a
a.prototype["$i"+a.name]=a
if(b!=null){if(z){a.prototype.__proto__=b.prototype
return}var t=Object.create(b.prototype)
copyProperties(a.prototype,t)
a.prototype=t}}function inheritMany(a,b){for(var t=0;t<b.length;t++)inherit(b[t],a)}function mixin(a,b){mixinProperties(b.prototype,a.prototype)
a.prototype.constructor=a}function lazyOld(a,b,c,d){var t=a
a[b]=t
a[c]=function(){a[c]=function(){H.hL(b)}
var s
var r=d
try{if(a[b]===t){s=a[b]=r
s=a[b]=d()}else s=a[b]}finally{if(s===r)a[b]=null
a[c]=function(){return this[b]}}return s}}function lazy(a,b,c,d){var t=a
a[b]=t
a[c]=function(){if(a[b]===t)a[b]=d()
a[c]=function(){return this[b]}
return a[b]}}function lazyFinal(a,b,c,d){var t=a
a[b]=t
a[c]=function(){if(a[b]===t){var s=d()
if(a[b]!==t)H.hM(b)
a[b]=s}a[c]=function(){return this[b]}
return a[b]}}function makeConstList(a){a.immutable$list=Array
a.fixed$length=Array
return a}function convertToFastObject(a){function t(){}t.prototype=a
new t()
return a}function convertAllToFastObject(a){for(var t=0;t<a.length;++t)convertToFastObject(a[t])}var y=0
function tearOffGetter(a,b,c,d,e){return e?new Function("funcs","applyTrampolineIndex","reflectionInfo","name","H","c","return function tearOff_"+d+y+++"(receiver) {"+"if (c === null) c = "+"H.e8"+"("+"this, funcs, applyTrampolineIndex, reflectionInfo, false, true, name);"+"return new c(this, funcs[0], receiver, name);"+"}")(a,b,c,d,H,null):new Function("funcs","applyTrampolineIndex","reflectionInfo","name","H","c","return function tearOff_"+d+y+++"() {"+"if (c === null) c = "+"H.e8"+"("+"this, funcs, applyTrampolineIndex, reflectionInfo, false, false, name);"+"return new c(this, funcs[0], null, name);"+"}")(a,b,c,d,H,null)}function tearOff(a,b,c,d,e,f){var t=null
return d?function(){if(t===null)t=H.e8(this,a,b,c,true,false,e).prototype
return t}:tearOffGetter(a,b,c,e,f)}var x=0
function installTearOff(a,b,c,d,e,f,g,h,i,j){var t=[]
for(var s=0;s<h.length;s++){var r=h[s]
if(typeof r=="string")r=a[r]
r.$callName=g[s]
t.push(r)}var r=t[0]
r.$R=e
r.$D=f
var q=i
if(typeof q=="number")q+=x
var p=h[0]
r.$stubName=p
var o=tearOff(t,j||0,q,c,p,d)
a[b]=o
if(c)r.$tearOff=o}function installStaticTearOff(a,b,c,d,e,f,g,h){return installTearOff(a,b,true,false,c,d,e,f,g,h)}function installInstanceTearOff(a,b,c,d,e,f,g,h,i){return installTearOff(a,b,false,c,d,e,f,g,h,i)}function setOrUpdateInterceptorsByTag(a){var t=v.interceptorsByTag
if(!t){v.interceptorsByTag=a
return}copyProperties(a,t)}function setOrUpdateLeafTags(a){var t=v.leafTags
if(!t){v.leafTags=a
return}copyProperties(a,t)}function updateTypes(a){var t=v.types
var s=t.length
t.push.apply(t,a)
return s}function updateHolder(a,b){copyProperties(b,a)
return a}var hunkHelpers=function(){var t=function(a,b,c,d,e){return function(f,g,h,i){return installInstanceTearOff(f,g,a,b,c,d,[h],i,e)}},s=function(a,b,c,d){return function(e,f,g,h){return installStaticTearOff(e,f,a,b,c,[g],h,d)}}
return{inherit:inherit,inheritMany:inheritMany,mixin:mixin,installStaticTearOff:installStaticTearOff,installInstanceTearOff:installInstanceTearOff,_instance_0u:t(0,0,null,["$0"],0),_instance_1u:t(0,1,null,["$1"],0),_instance_2u:t(0,2,null,["$2"],0),_instance_0i:t(1,0,null,["$0"],0),_instance_1i:t(1,1,null,["$1"],0),_instance_2i:t(1,2,null,["$2"],0),_static_0:s(0,null,["$0"],0),_static_1:s(1,null,["$1"],0),_static_2:s(2,null,["$2"],0),makeConstList:makeConstList,lazy:lazy,lazyFinal:lazyFinal,lazyOld:lazyOld,updateHolder:updateHolder,convertToFastObject:convertToFastObject,setFunctionNamesIfNecessary:setFunctionNamesIfNecessary,updateTypes:updateTypes,setOrUpdateInterceptorsByTag:setOrUpdateInterceptorsByTag,setOrUpdateLeafTags:setOrUpdateLeafTags}}()
function initializeDeferredHunk(a){x=v.types.length
a(hunkHelpers,v,w,$)}function getGlobalFromName(a){for(var t=0;t<w.length;t++){if(w[t]==C)continue
if(w[t][a])return w[t][a]}}var C={},H={dU:function dU(){},
eu:function(a,b,c,d){P.dW(b,"start")
return new H.aY(a,b,c,d.D("aY<0>"))},
aK:function aK(a){this.a=a},
aA:function aA(){},
ak:function ak(){},
aY:function aY(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.$ti=d},
aN:function aN(a,b){var _=this
_.a=a
_.b=b
_.c=0
_.d=null},
aO:function aO(a,b,c){this.a=a
this.b=b
this.$ti=c},
aZ:function aZ(a,b,c){this.a=a
this.b=b
this.$ti=c},
c6:function c6(a,b){this.a=a
this.b=b},
f_:function(a){var t,s=H.eZ(a)
if(s!=null)return s
t="minified:"+a
return t},
hE:function(a,b){var t
if(b!=null){t=b.x
if(t!=null)return t}return u.p.b(a)},
i:function(a){var t
if(typeof a=="string")return a
if(typeof a=="number"){if(a!==0)return""+a}else if(!0===a)return"true"
else if(!1===a)return"false"
else if(a==null)return"null"
t=J.bl(a)
return t},
aS:function(a){var t=a.$identityHash
if(t==null){t=Math.random()*0x3fffffff|0
a.$identityHash=t}return t},
dd:function(a){return H.fz(a)},
fz:function(a){var t,s,r,q
if(a instanceof P.u)return H.L(H.ae(a),null)
if(J.bg(a)===C.x||u.o.b(a)){t=C.h(a)
s=t!=="Object"&&t!==""
if(s)return t
r=a.constructor
if(typeof r=="function"){q=r.name
if(typeof q=="string")s=q!=="Object"&&q!==""
else s=!1
if(s)return q}}return H.L(H.ae(a),null)},
dI:function(a){throw H.f(H.hp(a))},
k:function(a,b){if(a==null)J.m(a)
throw H.f(H.e9(a,b))},
e9:function(a,b){var t,s="index"
if(!H.eP(b))return new P.U(!0,b,s,null)
t=J.m(a)
if(b<0||b>=t)return P.bD(b,a,s,null,t)
return P.fA(b,s)},
hp:function(a){return new P.U(!0,a,null,null)},
f:function(a){var t,s
if(a==null)a=new P.bP()
t=new Error()
t.dartException=a
s=H.hN
if("defineProperty" in Object){Object.defineProperty(t,"message",{get:s})
t.name=""}else t.toString=s
return t},
hN:function(){return J.bl(this.dartException)},
ag:function(a){throw H.f(a)},
T:function(a){throw H.f(P.aj(a))},
Y:function(a){var t,s,r,q,p,o
a=H.hK(a.replace(String({}),"$receiver$"))
t=a.match(/\\\$[a-zA-Z]+\\\$/g)
if(t==null)t=H.d([],u.s)
s=t.indexOf("\\$arguments\\$")
r=t.indexOf("\\$argumentsExpr\\$")
q=t.indexOf("\\$expr\\$")
p=t.indexOf("\\$method\\$")
o=t.indexOf("\\$receiver\\$")
return new H.dg(a.replace(new RegExp("\\\\\\$arguments\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$argumentsExpr\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$expr\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$method\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$receiver\\\\\\$","g"),"((?:x|[^x])*)"),s,r,q,p,o)},
dh:function(a){return function($expr$){var $argumentsExpr$="$arguments$"
try{$expr$.$method$($argumentsExpr$)}catch(t){return t.message}}(a)},
ex:function(a){return function($expr$){try{$expr$.$method$}catch(t){return t.message}}(a)},
dV:function(a,b){var t=b==null,s=t?null:b.method
return new H.bH(a,s,t?null:b.receiver)},
bj:function(a){if(a==null)return new H.d8(a)
if(typeof a!=="object")return a
if("dartException" in a)return H.af(a,a.dartException)
return H.ho(a)},
af:function(a,b){if(u.C.b(b))if(b.$thrownJsError==null)b.$thrownJsError=a
return b},
ho:function(a){var t,s,r,q,p,o,n,m,l,k,j,i,h,g,f=null
if(!("message" in a))return a
t=a.message
if("number" in a&&typeof a.number=="number"){s=a.number
r=s&65535
if((C.b.bA(s,16)&8191)===10)switch(r){case 438:return H.af(a,H.dV(H.i(t)+" (Error "+r+")",f))
case 445:case 5007:q=H.i(t)+" (Error "+r+")"
return H.af(a,new H.aR(q,f))}}if(a instanceof TypeError){p=$.f1()
o=$.f2()
n=$.f3()
m=$.f4()
l=$.f7()
k=$.f8()
j=$.f6()
$.f5()
i=$.fa()
h=$.f9()
g=p.K(t)
if(g!=null)return H.af(a,H.dV(t,g))
else{g=o.K(t)
if(g!=null){g.method="call"
return H.af(a,H.dV(t,g))}else{g=n.K(t)
if(g==null){g=m.K(t)
if(g==null){g=l.K(t)
if(g==null){g=k.K(t)
if(g==null){g=j.K(t)
if(g==null){g=m.K(t)
if(g==null){g=i.K(t)
if(g==null){g=h.K(t)
q=g!=null}else q=!0}else q=!0}else q=!0}else q=!0}else q=!0}else q=!0}else q=!0
if(q)return H.af(a,new H.aR(t,g==null?f:g.method))}}return H.af(a,new H.c4(typeof t=="string"?t:""))}if(a instanceof RangeError){if(typeof t=="string"&&t.indexOf("call stack")!==-1)return new P.aW()
t=function(b){try{return String(b)}catch(e){}return null}(a)
return H.af(a,new P.U(!1,f,f,typeof t=="string"?t.replace(/^RangeError:\s*/,""):t))}if(typeof InternalError=="function"&&a instanceof InternalError)if(typeof t=="string"&&t==="too much recursion")return new P.aW()
return a},
hw:function(a){var t
if(a==null)return new H.cI(a)
t=a.$cachedTrace
if(t!=null)return t
return a.$cachedTrace=new H.cI(a)},
hD:function(a,b,c,d,e,f){switch(b){case 0:return a.$0()
case 1:return a.$1(c)
case 2:return a.$2(c,d)
case 3:return a.$3(c,d,e)
case 4:return a.$4(c,d,e,f)}throw H.f(new P.dp("Unsupported number of arguments for wrapped closure"))},
bf:function(a,b){var t
if(a==null)return null
t=a.$identity
if(!!t)return t
t=function(c,d,e){return function(f,g,h,i){return e(c,d,f,g,h,i)}}(a,b,H.hD)
a.$identity=t
return t},
fr:function(a,b,c,d,e,f,g){var t,s,r,q,p,o,n,m=b[0],l=m.$callName,k=e?Object.create(new H.bY().constructor.prototype):Object.create(new H.ai(null,null,null,"").constructor.prototype)
k.$initialize=k.constructor
if(e)t=function static_tear_off(){this.$initialize()}
else{s=$.V
if(typeof s!=="number")return s.N()
$.V=s+1
s=new Function("a,b,c,d"+s,"this.$initialize(a,b,c,d"+s+")")
t=s}k.constructor=t
t.prototype=k
if(!e){r=H.ei(a,m,f)
r.$reflectionInfo=d}else{k.$static_name=g
r=m}k.$S=H.fn(d,e,f)
k[l]=r
for(q=r,p=1;p<b.length;++p){o=b[p]
n=o.$callName
if(n!=null){o=e?o:H.ei(a,o,f)
k[n]=o}if(p===c){o.$reflectionInfo=d
q=o}}k.$C=q
k.$R=m.$R
k.$D=m.$D
return t},
fn:function(a,b,c){var t
if(typeof a=="number")return function(d,e){return function(){return d(e)}}(H.eV,a)
if(typeof a=="string"){if(b)throw H.f("Cannot compute signature for static tearoff.")
t=c?H.fl:H.fk
return function(d,e){return function(){return e(this,d)}}(a,t)}throw H.f("Error in functionType of tearoff")},
fo:function(a,b,c,d){var t=H.eh
switch(b?-1:a){case 0:return function(e,f){return function(){return f(this)[e]()}}(c,t)
case 1:return function(e,f){return function(g){return f(this)[e](g)}}(c,t)
case 2:return function(e,f){return function(g,h){return f(this)[e](g,h)}}(c,t)
case 3:return function(e,f){return function(g,h,i){return f(this)[e](g,h,i)}}(c,t)
case 4:return function(e,f){return function(g,h,i,j){return f(this)[e](g,h,i,j)}}(c,t)
case 5:return function(e,f){return function(g,h,i,j,k){return f(this)[e](g,h,i,j,k)}}(c,t)
default:return function(e,f){return function(){return e.apply(f(this),arguments)}}(d,t)}},
ei:function(a,b,c){var t,s,r,q,p,o,n
if(c)return H.fq(a,b)
t=b.$stubName
s=b.length
r=a[t]
q=b==null?r==null:b===r
p=!q||s>=27
if(p)return H.fo(s,!q,t,b)
if(s===0){q=$.V
if(typeof q!=="number")return q.N()
$.V=q+1
o="self"+q
q="return function(){var "+o+" = this."
p=$.aw
return new Function(q+(p==null?$.aw=H.cW("self"):p)+";return "+o+"."+H.i(t)+"();}")()}n="abcdefghijklmnopqrstuvwxyz".split("").splice(0,s).join(",")
q=$.V
if(typeof q!=="number")return q.N()
$.V=q+1
n+=q
q="return function("+n+"){return this."
p=$.aw
return new Function(q+(p==null?$.aw=H.cW("self"):p)+"."+H.i(t)+"("+n+");}")()},
fp:function(a,b,c,d){var t=H.eh,s=H.fm
switch(b?-1:a){case 0:throw H.f(new H.bV("Intercepted function with no arguments."))
case 1:return function(e,f,g){return function(){return f(this)[e](g(this))}}(c,t,s)
case 2:return function(e,f,g){return function(h){return f(this)[e](g(this),h)}}(c,t,s)
case 3:return function(e,f,g){return function(h,i){return f(this)[e](g(this),h,i)}}(c,t,s)
case 4:return function(e,f,g){return function(h,i,j){return f(this)[e](g(this),h,i,j)}}(c,t,s)
case 5:return function(e,f,g){return function(h,i,j,k){return f(this)[e](g(this),h,i,j,k)}}(c,t,s)
case 6:return function(e,f,g){return function(h,i,j,k,l){return f(this)[e](g(this),h,i,j,k,l)}}(c,t,s)
default:return function(e,f,g,h){return function(){h=[g(this)]
Array.prototype.push.apply(h,arguments)
return e.apply(f(this),h)}}(d,t,s)}},
fq:function(a,b){var t,s,r,q,p,o,n,m=$.aw
if(m==null)m=$.aw=H.cW("self")
t=$.eg
if(t==null)t=$.eg=H.cW("receiver")
s=b.$stubName
r=b.length
q=a[s]
p=b==null?q==null:b===q
o=!p||r>=28
if(o)return H.fp(r,!p,s,b)
if(r===1){p="return function(){return this."+m+"."+H.i(s)+"(this."+t+");"
o=$.V
if(typeof o!=="number")return o.N()
$.V=o+1
return new Function(p+o+"}")()}n="abcdefghijklmnopqrstuvwxyz".split("").splice(0,r-1).join(",")
p="return function("+n+"){return this."+m+"."+H.i(s)+"(this."+t+", "+n+");"
o=$.V
if(typeof o!=="number")return o.N()
$.V=o+1
return new Function(p+o+"}")()},
e8:function(a,b,c,d,e,f,g){return H.fr(a,b,c,d,!!e,!!f,g)},
fk:function(a,b){return H.cO(v.typeUniverse,H.ae(a.a),b)},
fl:function(a,b){return H.cO(v.typeUniverse,H.ae(a.c),b)},
eh:function(a){return a.a},
fm:function(a){return a.c},
cW:function(a){var t,s,r,q=new H.ai("self","target","receiver","name"),p=J.en(Object.getOwnPropertyNames(q))
for(t=p.length,s=0;s<t;++s){r=p[s]
if(q[r]===a)return r}throw H.f(P.ef("Field name "+a+" not found."))},
hL:function(a){throw H.f(new P.bu(a))},
hv:function(a){return v.getIsolateTag(a)},
hM:function(a){return H.ag(new H.aK(a))},
it:function(a,b,c){Object.defineProperty(a,b,{value:c,enumerable:false,writable:true,configurable:true})},
hG:function(a){var t,s,r,q,p,o=$.eU.$1(a),n=$.dG[o]
if(n!=null){Object.defineProperty(a,v.dispatchPropertyName,{value:n,enumerable:false,writable:true,configurable:true})
return n.i}t=$.dM[o]
if(t!=null)return t
s=v.interceptorsByTag[o]
if(s==null){r=$.eR.$2(a,o)
if(r!=null){n=$.dG[r]
if(n!=null){Object.defineProperty(a,v.dispatchPropertyName,{value:n,enumerable:false,writable:true,configurable:true})
return n.i}t=$.dM[r]
if(t!=null)return t
s=v.interceptorsByTag[r]
o=r}}if(s==null)return null
t=s.prototype
q=o[0]
if(q==="!"){n=H.dO(t)
$.dG[o]=n
Object.defineProperty(a,v.dispatchPropertyName,{value:n,enumerable:false,writable:true,configurable:true})
return n.i}if(q==="~"){$.dM[o]=t
return t}if(q==="-"){p=H.dO(t)
Object.defineProperty(Object.getPrototypeOf(a),v.dispatchPropertyName,{value:p,enumerable:false,writable:true,configurable:true})
return p.i}if(q==="+")return H.eX(a,t)
if(q==="*")throw H.f(P.ey(o))
if(v.leafTags[o]===true){p=H.dO(t)
Object.defineProperty(Object.getPrototypeOf(a),v.dispatchPropertyName,{value:p,enumerable:false,writable:true,configurable:true})
return p.i}else return H.eX(a,t)},
eX:function(a,b){var t=Object.getPrototypeOf(a)
Object.defineProperty(t,v.dispatchPropertyName,{value:J.eb(b,t,null,null),enumerable:false,writable:true,configurable:true})
return b},
dO:function(a){return J.eb(a,!1,null,!!a.$ibG)},
hI:function(a,b,c){var t=b.prototype
if(v.leafTags[a]===true)return H.dO(t)
else return J.eb(t,c,null,null)},
hA:function(){if(!0===$.ea)return
$.ea=!0
H.hB()},
hB:function(){var t,s,r,q,p,o,n,m
$.dG=Object.create(null)
$.dM=Object.create(null)
H.hz()
t=v.interceptorsByTag
s=Object.getOwnPropertyNames(t)
if(typeof window!="undefined"){window
r=function(){}
for(q=0;q<s.length;++q){p=s[q]
o=$.eY.$1(p)
if(o!=null){n=H.hI(p,t[p],o)
if(n!=null){Object.defineProperty(o,v.dispatchPropertyName,{value:n,enumerable:false,writable:true,configurable:true})
r.prototype=o}}}}for(q=0;q<s.length;++q){p=s[q]
if(/^[A-Za-z_]/.test(p)){m=t[p]
t["!"+p]=m
t["~"+p]=m
t["-"+p]=m
t["+"+p]=m
t["*"+p]=m}}},
hz:function(){var t,s,r,q,p,o,n=C.p()
n=H.au(C.q,H.au(C.r,H.au(C.i,H.au(C.i,H.au(C.t,H.au(C.u,H.au(C.v(C.h),n)))))))
if(typeof dartNativeDispatchHooksTransformer!="undefined"){t=dartNativeDispatchHooksTransformer
if(typeof t=="function")t=[t]
if(t.constructor==Array)for(s=0;s<t.length;++s){r=t[s]
if(typeof r=="function")n=r(n)||n}}q=n.getTag
p=n.getUnknownTag
o=n.prototypeForTag
$.eU=new H.dJ(q)
$.eR=new H.dK(p)
$.eY=new H.dL(o)},
au:function(a,b){return a(b)||b},
hK:function(a){if(/[[\]{}()*+?.\\^$|]/.test(a))return a.replace(/[[\]{}()*+?.\\^$|]/g,"\\$&")
return a},
dg:function dg(a,b,c,d,e,f){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f},
aR:function aR(a,b){this.a=a
this.b=b},
bH:function bH(a,b,c){this.a=a
this.b=b
this.c=c},
c4:function c4(a){this.a=a},
d8:function d8(a){this.a=a},
cI:function cI(a){this.a=a
this.b=null},
a6:function a6(){},
c_:function c_(){},
bY:function bY(){},
ai:function ai(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
bV:function bV(a){this.a=a},
aJ:function aJ(a){var _=this
_.a=0
_.f=_.e=_.d=_.c=_.b=null
_.r=0
_.$ti=a},
d1:function d1(a,b){var _=this
_.a=a
_.b=b
_.d=_.c=null},
aL:function aL(a,b){this.a=a
this.$ti=b},
bK:function bK(a,b){var _=this
_.a=a
_.b=b
_.d=_.c=null},
dJ:function dJ(a){this.a=a},
dK:function dK(a){this.a=a},
dL:function dL(a){this.a=a},
er:function(a,b){var t=b.c
return t==null?b.c=H.e1(a,b.z,!0):t},
eq:function(a,b){var t=b.c
return t==null?b.c=H.b8(a,"el",[b.z]):t},
es:function(a){var t=a.y
if(t===6||t===7||t===8)return H.es(a.z)
return t===11||t===12},
fC:function(a){return a.cy},
eT:function(a){return H.e2(v.typeUniverse,a,!1)},
a4:function(a,b,c,a0){var t,s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d=b.y
switch(d){case 5:case 1:case 2:case 3:case 4:return b
case 6:t=b.z
s=H.a4(a,t,c,a0)
if(s===t)return b
return H.eI(a,s,!0)
case 7:t=b.z
s=H.a4(a,t,c,a0)
if(s===t)return b
return H.e1(a,s,!0)
case 8:t=b.z
s=H.a4(a,t,c,a0)
if(s===t)return b
return H.eH(a,s,!0)
case 9:r=b.Q
q=H.be(a,r,c,a0)
if(q===r)return b
return H.b8(a,b.z,q)
case 10:p=b.z
o=H.a4(a,p,c,a0)
n=b.Q
m=H.be(a,n,c,a0)
if(o===p&&m===n)return b
return H.e_(a,o,m)
case 11:l=b.z
k=H.a4(a,l,c,a0)
j=b.Q
i=H.hl(a,j,c,a0)
if(k===l&&i===j)return b
return H.eG(a,k,i)
case 12:h=b.Q
a0+=h.length
g=H.be(a,h,c,a0)
p=b.z
o=H.a4(a,p,c,a0)
if(g===h&&o===p)return b
return H.e0(a,o,g,!0)
case 13:f=b.z
if(f<a0)return b
e=c[f-a0]
if(e==null)return b
return e
default:throw H.f(P.cU("Attempted to substitute unexpected RTI kind "+d))}},
be:function(a,b,c,d){var t,s,r,q,p=b.length,o=[]
for(t=!1,s=0;s<p;++s){r=b[s]
q=H.a4(a,r,c,d)
if(q!==r)t=!0
o.push(q)}return t?o:b},
hm:function(a,b,c,d){var t,s,r,q,p,o,n=b.length,m=[]
for(t=!1,s=0;s<n;s+=3){r=b[s]
q=b[s+1]
p=b[s+2]
o=H.a4(a,p,c,d)
if(o!==p)t=!0
m.push(r)
m.push(q)
m.push(o)}return t?m:b},
hl:function(a,b,c,d){var t,s=b.a,r=H.be(a,s,c,d),q=b.b,p=H.be(a,q,c,d),o=b.c,n=H.hm(a,o,c,d)
if(r===s&&p===q&&n===o)return b
t=new H.co()
t.a=r
t.b=p
t.c=n
return t},
d:function(a,b){a[v.arrayRti]=b
return a},
ht:function(a){var t=a.$S
if(t!=null){if(typeof t=="number")return H.eV(t)
return a.$S()}return null},
eW:function(a,b){var t
if(H.es(b))if(a instanceof H.a6){t=H.ht(a)
if(t!=null)return t}return H.ae(a)},
ae:function(a){var t
if(a instanceof P.u){t=a.$ti
return t!=null?t:H.e4(a)}if(Array.isArray(a))return H.dE(a)
return H.e4(J.bg(a))},
dE:function(a){var t=a[v.arrayRti],s=u.r
if(t==null)return s
if(t.constructor!==s.constructor)return s
return t},
ad:function(a){var t=a.$ti
return t!=null?t:H.e4(a)},
e4:function(a){var t=a.constructor,s=t.$ccache
if(s!=null)return s
return H.h6(a,t)},
h6:function(a,b){var t=a instanceof H.a6?a.__proto__.__proto__.constructor:b,s=H.fY(v.typeUniverse,t.name)
b.$ccache=s
return s},
eV:function(a){var t,s=v.types,r=s[a]
if(typeof r=="string"){t=H.e2(v.typeUniverse,r,!1)
s[a]=t
return t}return r},
h5:function(a){var t,s,r,q=this
if(q===u.K)return H.bb(q,a,H.h9)
if(!H.Z(q))if(!(q===u._))t=!1
else t=!0
else t=!0
if(t)return H.bb(q,a,H.hc)
t=q.y
s=t===6?q.z:q
if(s===u.S)r=H.eP
else if(s===u.i||s===u.H)r=H.h8
else if(s===u.N)r=H.ha
else r=s===u.w?H.eN:null
if(r!=null)return H.bb(q,a,r)
if(s.y===9){t=s.z
if(s.Q.every(H.hF)){q.r="$i"+t
return H.bb(q,a,H.hb)}}else if(t===7)return H.bb(q,a,H.h3)
return H.bb(q,a,H.h1)},
bb:function(a,b,c){a.b=c
return a.b(b)},
h4:function(a){var t,s=this,r=H.h0
if(!H.Z(s))if(!(s===u._))t=!1
else t=!0
else t=!0
if(t)r=H.h_
else if(s===u.K)r=H.fZ
else{t=H.bi(s)
if(t)r=H.h2}s.a=r
return s.a(a)},
e7:function(a){var t,s=a.y
if(!H.Z(a))if(!(a===u._))if(!(a===u.A))if(s!==7)t=s===8&&H.e7(a.z)||a===u.P||a===u.T
else t=!0
else t=!0
else t=!0
else t=!0
return t},
h1:function(a){var t=this
if(a==null)return H.e7(t)
return H.t(v.typeUniverse,H.eW(a,t),null,t,null)},
h3:function(a){if(a==null)return!0
return this.z.b(a)},
hb:function(a){var t,s=this
if(a==null)return H.e7(s)
t=s.r
if(a instanceof P.u)return!!a[t]
return!!J.bg(a)[t]},
h0:function(a){var t,s=this
if(a==null){t=H.bi(s)
if(t)return a}else if(s.b(a))return a
H.eL(a,s)},
h2:function(a){var t=this
if(a==null)return a
else if(t.b(a))return a
H.eL(a,t)},
eL:function(a,b){throw H.f(H.fO(H.ez(a,H.eW(a,b),H.L(b,null))))},
ez:function(a,b,c){var t=P.cZ(a),s=H.L(b==null?H.ae(a):b,null)
return t+": type '"+s+"' is not a subtype of type '"+c+"'"},
fO:function(a){return new H.b7("TypeError: "+a)},
E:function(a,b){return new H.b7("TypeError: "+H.ez(a,null,b))},
h9:function(a){return a!=null},
fZ:function(a){if(a!=null)return a
throw H.f(H.E(a,"Object"))},
hc:function(a){return!0},
h_:function(a){return a},
eN:function(a){return!0===a||!1===a},
id:function(a){if(!0===a)return!0
if(!1===a)return!1
throw H.f(H.E(a,"bool"))},
ig:function(a){if(!0===a)return!0
if(!1===a)return!1
if(a==null)return a
throw H.f(H.E(a,"bool"))},
ie:function(a){if(!0===a)return!0
if(!1===a)return!1
if(a==null)return a
throw H.f(H.E(a,"bool?"))},
ih:function(a){if(typeof a=="number")return a
throw H.f(H.E(a,"double"))},
ij:function(a){if(typeof a=="number")return a
if(a==null)return a
throw H.f(H.E(a,"double"))},
ii:function(a){if(typeof a=="number")return a
if(a==null)return a
throw H.f(H.E(a,"double?"))},
eP:function(a){return typeof a=="number"&&Math.floor(a)===a},
ik:function(a){if(typeof a=="number"&&Math.floor(a)===a)return a
throw H.f(H.E(a,"int"))},
im:function(a){if(typeof a=="number"&&Math.floor(a)===a)return a
if(a==null)return a
throw H.f(H.E(a,"int"))},
il:function(a){if(typeof a=="number"&&Math.floor(a)===a)return a
if(a==null)return a
throw H.f(H.E(a,"int?"))},
h8:function(a){return typeof a=="number"},
io:function(a){if(typeof a=="number")return a
throw H.f(H.E(a,"num"))},
iq:function(a){if(typeof a=="number")return a
if(a==null)return a
throw H.f(H.E(a,"num"))},
ip:function(a){if(typeof a=="number")return a
if(a==null)return a
throw H.f(H.E(a,"num?"))},
ha:function(a){return typeof a=="string"},
e3:function(a){if(typeof a=="string")return a
throw H.f(H.E(a,"String"))},
is:function(a){if(typeof a=="string")return a
if(a==null)return a
throw H.f(H.E(a,"String"))},
ir:function(a){if(typeof a=="string")return a
if(a==null)return a
throw H.f(H.E(a,"String?"))},
hh:function(a,b){var t,s,r
for(t="",s="",r=0;r<a.length;++r,s=", ")t+=s+H.L(a[r],b)
return t},
eM:function(a3,a4,a5){var t,s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2=", "
if(a5!=null){t=a5.length
if(a4==null){a4=H.d([],u.s)
s=null}else s=a4.length
r=a4.length
for(q=t;q>0;--q)a4.push("T"+(r+q))
for(p=u.X,o=u._,n="<",m="",q=0;q<t;++q,m=a2){n+=m
l=a4.length
k=l-1-q
if(k<0)return H.k(a4,k)
n=C.j.N(n,a4[k])
j=a5[q]
i=j.y
if(!(i===2||i===3||i===4||i===5||j===p))if(!(j===o))l=!1
else l=!0
else l=!0
if(!l)n+=" extends "+H.L(j,a4)}n+=">"}else{n=""
s=null}p=a3.z
h=a3.Q
g=h.a
f=g.length
e=h.b
d=e.length
c=h.c
b=c.length
a=H.L(p,a4)
for(a0="",a1="",q=0;q<f;++q,a1=a2)a0+=a1+H.L(g[q],a4)
if(d>0){a0+=a1+"["
for(a1="",q=0;q<d;++q,a1=a2)a0+=a1+H.L(e[q],a4)
a0+="]"}if(b>0){a0+=a1+"{"
for(a1="",q=0;q<b;q+=3,a1=a2){a0+=a1
if(c[q+1])a0+="required "
a0+=H.L(c[q+2],a4)+" "+c[q]}a0+="}"}if(s!=null){a4.toString
a4.length=s}return n+"("+a0+") => "+a},
L:function(a,b){var t,s,r,q,p,o,n,m=a.y
if(m===5)return"erased"
if(m===2)return"dynamic"
if(m===3)return"void"
if(m===1)return"Never"
if(m===4)return"any"
if(m===6){t=H.L(a.z,b)
return t}if(m===7){s=a.z
t=H.L(s,b)
r=s.y
return(r===11||r===12?"("+t+")":t)+"?"}if(m===8)return"FutureOr<"+H.L(a.z,b)+">"
if(m===9){q=H.hn(a.z)
p=a.Q
return p.length!==0?q+("<"+H.hh(p,b)+">"):q}if(m===11)return H.eM(a,b,null)
if(m===12)return H.eM(a.z,b,a.Q)
if(m===13){o=a.z
n=b.length
o=n-1-o
if(o<0||o>=n)return H.k(b,o)
return b[o]}return"?"},
hn:function(a){var t,s=H.eZ(a)
if(s!=null)return s
t="minified:"+a
return t},
eJ:function(a,b){var t=a.tR[b]
for(;typeof t=="string";)t=a.tR[t]
return t},
fY:function(a,b){var t,s,r,q,p,o=a.eT,n=o[b]
if(n==null)return H.e2(a,b,!1)
else if(typeof n=="number"){t=n
s=H.b9(a,5,"#")
r=[]
for(q=0;q<t;++q)r.push(s)
p=H.b8(a,b,r)
o[b]=p
return p}else return n},
fW:function(a,b){return H.eK(a.tR,b)},
fV:function(a,b){return H.eK(a.eT,b)},
e2:function(a,b,c){var t,s=a.eC,r=s.get(b)
if(r!=null)return r
t=H.eE(H.eC(a,null,b,c))
s.set(b,t)
return t},
cO:function(a,b,c){var t,s,r=b.ch
if(r==null)r=b.ch=new Map()
t=r.get(c)
if(t!=null)return t
s=H.eE(H.eC(a,b,c,!0))
r.set(c,s)
return s},
fX:function(a,b,c){var t,s,r,q=b.cx
if(q==null)q=b.cx=new Map()
t=c.cy
s=q.get(t)
if(s!=null)return s
r=H.e_(a,b,c.y===10?c.Q:[c])
q.set(t,r)
return r},
a3:function(a,b){b.a=H.h4
b.b=H.h5
return b},
b9:function(a,b,c){var t,s,r=a.eC.get(c)
if(r!=null)return r
t=new H.O(null,null)
t.y=b
t.cy=c
s=H.a3(a,t)
a.eC.set(c,s)
return s},
eI:function(a,b,c){var t,s=b.cy+"*",r=a.eC.get(s)
if(r!=null)return r
t=H.fT(a,b,s,c)
a.eC.set(s,t)
return t},
fT:function(a,b,c,d){var t,s,r
if(d){t=b.y
if(!H.Z(b))s=b===u.P||b===u.T||t===7||t===6
else s=!0
if(s)return b}r=new H.O(null,null)
r.y=6
r.z=b
r.cy=c
return H.a3(a,r)},
e1:function(a,b,c){var t,s=b.cy+"?",r=a.eC.get(s)
if(r!=null)return r
t=H.fS(a,b,s,c)
a.eC.set(s,t)
return t},
fS:function(a,b,c,d){var t,s,r,q
if(d){t=b.y
if(!H.Z(b))if(!(b===u.P||b===u.T))if(t!==7)s=t===8&&H.bi(b.z)
else s=!0
else s=!0
else s=!0
if(s)return b
else if(t===1||b===u.A)return u.P
else if(t===6){r=b.z
if(r.y===8&&H.bi(r.z))return r
else return H.er(a,b)}}q=new H.O(null,null)
q.y=7
q.z=b
q.cy=c
return H.a3(a,q)},
eH:function(a,b,c){var t,s=b.cy+"/",r=a.eC.get(s)
if(r!=null)return r
t=H.fQ(a,b,s,c)
a.eC.set(s,t)
return t},
fQ:function(a,b,c,d){var t,s,r
if(d){t=b.y
if(!H.Z(b))if(!(b===u._))s=!1
else s=!0
else s=!0
if(s||b===u.K)return b
else if(t===1)return H.b8(a,"el",[b])
else if(b===u.P||b===u.T)return u.O}r=new H.O(null,null)
r.y=8
r.z=b
r.cy=c
return H.a3(a,r)},
fU:function(a,b){var t,s,r=""+b+"^",q=a.eC.get(r)
if(q!=null)return q
t=new H.O(null,null)
t.y=13
t.z=b
t.cy=r
s=H.a3(a,t)
a.eC.set(r,s)
return s},
cN:function(a){var t,s,r,q=a.length
for(t="",s="",r=0;r<q;++r,s=",")t+=s+a[r].cy
return t},
fP:function(a){var t,s,r,q,p,o,n=a.length
for(t="",s="",r=0;r<n;r+=3,s=","){q=a[r]
p=a[r+1]?"!":":"
o=a[r+2].cy
t+=s+q+p+o}return t},
b8:function(a,b,c){var t,s,r,q=b
if(c.length!==0)q+="<"+H.cN(c)+">"
t=a.eC.get(q)
if(t!=null)return t
s=new H.O(null,null)
s.y=9
s.z=b
s.Q=c
if(c.length>0)s.c=c[0]
s.cy=q
r=H.a3(a,s)
a.eC.set(q,r)
return r},
e_:function(a,b,c){var t,s,r,q,p,o
if(b.y===10){t=b.z
s=b.Q.concat(c)}else{s=c
t=b}r=t.cy+(";<"+H.cN(s)+">")
q=a.eC.get(r)
if(q!=null)return q
p=new H.O(null,null)
p.y=10
p.z=t
p.Q=s
p.cy=r
o=H.a3(a,p)
a.eC.set(r,o)
return o},
eG:function(a,b,c){var t,s,r,q,p,o=b.cy,n=c.a,m=n.length,l=c.b,k=l.length,j=c.c,i=j.length,h="("+H.cN(n)
if(k>0){t=m>0?",":""
s=H.cN(l)
h+=t+"["+s+"]"}if(i>0){t=m>0?",":""
s=H.fP(j)
h+=t+"{"+s+"}"}r=o+(h+")")
q=a.eC.get(r)
if(q!=null)return q
p=new H.O(null,null)
p.y=11
p.z=b
p.Q=c
p.cy=r
s=H.a3(a,p)
a.eC.set(r,s)
return s},
e0:function(a,b,c,d){var t,s=b.cy+("<"+H.cN(c)+">"),r=a.eC.get(s)
if(r!=null)return r
t=H.fR(a,b,c,s,d)
a.eC.set(s,t)
return t},
fR:function(a,b,c,d,e){var t,s,r,q,p,o,n,m
if(e){t=c.length
s=new Array(t)
for(r=0,q=0;q<t;++q){p=c[q]
if(p.y===1){s[q]=p;++r}}if(r>0){o=H.a4(a,b,s,0)
n=H.be(a,c,s,0)
return H.e0(a,o,n,c!==n)}}m=new H.O(null,null)
m.y=12
m.z=b
m.Q=c
m.cy=d
return H.a3(a,m)},
eC:function(a,b,c,d){return{u:a,e:b,r:c,s:[],p:0,n:d}},
eE:function(a){var t,s,r,q,p,o,n,m,l,k,j,i=a.r,h=a.s
for(t=i.length,s=0;s<t;){r=i.charCodeAt(s)
if(r>=48&&r<=57)s=H.fJ(s+1,r,i,h)
else if((((r|32)>>>0)-97&65535)<26||r===95||r===36)s=H.eD(a,s,i,h,!1)
else if(r===46)s=H.eD(a,s,i,h,!0)
else{++s
switch(r){case 44:break
case 58:h.push(!1)
break
case 33:h.push(!0)
break
case 59:h.push(H.a2(a.u,a.e,h.pop()))
break
case 94:h.push(H.fU(a.u,h.pop()))
break
case 35:h.push(H.b9(a.u,5,"#"))
break
case 64:h.push(H.b9(a.u,2,"@"))
break
case 126:h.push(H.b9(a.u,3,"~"))
break
case 60:h.push(a.p)
a.p=h.length
break
case 62:q=a.u
p=h.splice(a.p)
H.dZ(a.u,a.e,p)
a.p=h.pop()
o=h.pop()
if(typeof o=="string")h.push(H.b8(q,o,p))
else{n=H.a2(q,a.e,o)
switch(n.y){case 11:h.push(H.e0(q,n,p,a.n))
break
default:h.push(H.e_(q,n,p))
break}}break
case 38:H.fK(a,h)
break
case 42:q=a.u
h.push(H.eI(q,H.a2(q,a.e,h.pop()),a.n))
break
case 63:q=a.u
h.push(H.e1(q,H.a2(q,a.e,h.pop()),a.n))
break
case 47:q=a.u
h.push(H.eH(q,H.a2(q,a.e,h.pop()),a.n))
break
case 40:h.push(a.p)
a.p=h.length
break
case 41:q=a.u
m=new H.co()
l=q.sEA
k=q.sEA
o=h.pop()
if(typeof o=="number")switch(o){case-1:l=h.pop()
break
case-2:k=h.pop()
break
default:h.push(o)
break}else h.push(o)
p=h.splice(a.p)
H.dZ(a.u,a.e,p)
a.p=h.pop()
m.a=p
m.b=l
m.c=k
h.push(H.eG(q,H.a2(q,a.e,h.pop()),m))
break
case 91:h.push(a.p)
a.p=h.length
break
case 93:p=h.splice(a.p)
H.dZ(a.u,a.e,p)
a.p=h.pop()
h.push(p)
h.push(-1)
break
case 123:h.push(a.p)
a.p=h.length
break
case 125:p=h.splice(a.p)
H.fM(a.u,a.e,p)
a.p=h.pop()
h.push(p)
h.push(-2)
break
default:throw"Bad character "+r}}}j=h.pop()
return H.a2(a.u,a.e,j)},
fJ:function(a,b,c,d){var t,s,r=b-48
for(t=c.length;a<t;++a){s=c.charCodeAt(a)
if(!(s>=48&&s<=57))break
r=r*10+(s-48)}d.push(r)
return a},
eD:function(a,b,c,d,e){var t,s,r,q,p,o,n=b+1
for(t=c.length;n<t;++n){s=c.charCodeAt(n)
if(s===46){if(e)break
e=!0}else{if(!((((s|32)>>>0)-97&65535)<26||s===95||s===36))r=s>=48&&s<=57
else r=!0
if(!r)break}}q=c.substring(b,n)
if(e){t=a.u
p=a.e
if(p.y===10)p=p.z
o=H.eJ(t,p.z)[q]
if(o==null)H.ag('No "'+q+'" in "'+H.fC(p)+'"')
d.push(H.cO(t,p,o))}else d.push(q)
return n},
fK:function(a,b){var t=b.pop()
if(0===t){b.push(H.b9(a.u,1,"0&"))
return}if(1===t){b.push(H.b9(a.u,4,"1&"))
return}throw H.f(P.cU("Unexpected extended operation "+H.i(t)))},
a2:function(a,b,c){if(typeof c=="string")return H.b8(a,c,a.sEA)
else if(typeof c=="number")return H.fL(a,b,c)
else return c},
dZ:function(a,b,c){var t,s=c.length
for(t=0;t<s;++t)c[t]=H.a2(a,b,c[t])},
fM:function(a,b,c){var t,s=c.length
for(t=2;t<s;t+=3)c[t]=H.a2(a,b,c[t])},
fL:function(a,b,c){var t,s,r=b.y
if(r===10){if(c===0)return b.z
t=b.Q
s=t.length
if(c<=s)return t[c-1]
c-=s
b=b.z
r=b.y}else if(c===0)return b
if(r!==9)throw H.f(P.cU("Indexed base must be an interface type"))
t=b.Q
if(c<=t.length)return t[c-1]
throw H.f(P.cU("Bad index "+c+" for "+b.i(0)))},
t:function(a,b,c,d,e){var t,s,r,q,p,o,n,m,l,k
if(b===d)return!0
if(!H.Z(d))if(!(d===u._))t=!1
else t=!0
else t=!0
if(t)return!0
s=b.y
if(s===4)return!0
if(H.Z(b))return!1
if(b.y!==1)t=!1
else t=!0
if(t)return!0
r=s===13
if(r)if(H.t(a,c[b.z],c,d,e))return!0
q=d.y
t=b===u.P||b===u.T
if(t){if(q===8)return H.t(a,b,c,d.z,e)
return d===u.P||d===u.T||q===7||q===6}if(d===u.K){if(s===8)return H.t(a,b.z,c,d,e)
if(s===6)return H.t(a,b.z,c,d,e)
return s!==7}if(s===6)return H.t(a,b.z,c,d,e)
if(q===6){t=H.er(a,d)
return H.t(a,b,c,t,e)}if(s===8){if(!H.t(a,b.z,c,d,e))return!1
return H.t(a,H.eq(a,b),c,d,e)}if(s===7){t=H.t(a,u.P,c,d,e)
return t&&H.t(a,b.z,c,d,e)}if(q===8){if(H.t(a,b,c,d.z,e))return!0
return H.t(a,b,c,H.eq(a,d),e)}if(q===7){t=H.t(a,b,c,u.P,e)
return t||H.t(a,b,c,d.z,e)}if(r)return!1
t=s!==11
if((!t||s===12)&&d===u.Z)return!0
if(q===12){if(b===u.g)return!0
if(s!==12)return!1
p=b.Q
o=d.Q
n=p.length
if(n!==o.length)return!1
c=c==null?p:p.concat(c)
e=e==null?o:o.concat(e)
for(m=0;m<n;++m){l=p[m]
k=o[m]
if(!H.t(a,l,c,k,e)||!H.t(a,k,e,l,c))return!1}return H.eO(a,b.z,c,d.z,e)}if(q===11){if(b===u.g)return!0
if(t)return!1
return H.eO(a,b,c,d,e)}if(s===9){if(q!==9)return!1
return H.h7(a,b,c,d,e)}return!1},
eO:function(a2,a3,a4,a5,a6){var t,s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1
if(!H.t(a2,a3.z,a4,a5.z,a6))return!1
t=a3.Q
s=a5.Q
r=t.a
q=s.a
p=r.length
o=q.length
if(p>o)return!1
n=o-p
m=t.b
l=s.b
k=m.length
j=l.length
if(p+k<o+j)return!1
for(i=0;i<p;++i){h=r[i]
if(!H.t(a2,q[i],a6,h,a4))return!1}for(i=0;i<n;++i){h=m[i]
if(!H.t(a2,q[p+i],a6,h,a4))return!1}for(i=0;i<j;++i){h=m[n+i]
if(!H.t(a2,l[i],a6,h,a4))return!1}g=t.c
f=s.c
e=g.length
d=f.length
for(c=0,b=0;b<d;b+=3){a=f[b]
for(;!0;){if(c>=e)return!1
a0=g[c]
c+=3
if(a<a0)return!1
a1=g[c-2]
if(a0<a){if(a1)return!1
continue}h=f[b+1]
if(a1&&!h)return!1
h=g[c-1]
if(!H.t(a2,f[b+2],a6,h,a4))return!1
break}}for(;c<e;){if(g[c+1])return!1
c+=3}return!0},
h7:function(a,b,c,d,e){var t,s,r,q,p,o,n,m,l=b.z,k=d.z
if(l===k){t=b.Q
s=d.Q
r=t.length
for(q=0;q<r;++q){p=t[q]
o=s[q]
if(!H.t(a,p,c,o,e))return!1}return!0}if(d===u.K)return!0
n=H.eJ(a,l)
if(n==null)return!1
m=n[k]
if(m==null)return!1
r=m.length
s=d.Q
for(q=0;q<r;++q)if(!H.t(a,H.cO(a,b,m[q]),c,s[q],e))return!1
return!0},
bi:function(a){var t,s=a.y
if(!(a===u.P||a===u.T))if(!H.Z(a))if(s!==7)if(!(s===6&&H.bi(a.z)))t=s===8&&H.bi(a.z)
else t=!0
else t=!0
else t=!0
else t=!0
return t},
hF:function(a){var t
if(!H.Z(a))if(!(a===u._))t=!1
else t=!0
else t=!0
return t},
Z:function(a){var t=a.y
return t===2||t===3||t===4||t===5||a===u.X},
eK:function(a,b){var t,s,r=Object.keys(b),q=r.length
for(t=0;t<q;++t){s=r[t]
a[s]=b[s]}},
O:function O(a,b){var _=this
_.a=a
_.b=b
_.x=_.r=_.c=null
_.y=0
_.cy=_.cx=_.ch=_.Q=_.z=null},
co:function co(){this.c=this.b=this.a=null},
cm:function cm(){},
b7:function b7(a){this.a=a},
eZ:function(a){return v.mangledGlobalNames[a]}},J={
eb:function(a,b,c,d){return{i:a,p:b,e:c,x:d}},
dH:function(a){var t,s,r,q,p,o=a[v.dispatchPropertyName]
if(o==null)if($.ea==null){H.hA()
o=a[v.dispatchPropertyName]}if(o!=null){t=o.p
if(!1===t)return o.i
if(!0===t)return a
s=Object.getPrototypeOf(a)
if(t===s)return o.i
if(o.e===s)throw H.f(P.ey("Return interceptor for "+H.i(t(a,o))))}r=a.constructor
if(r==null)q=null
else{p=$.dq
if(p==null)p=$.dq=v.getIsolateTag("_$dart_js")
q=r[p]}if(q!=null)return q
q=H.hG(a)
if(q!=null)return q
if(typeof a=="function")return C.z
t=Object.getPrototypeOf(a)
if(t==null)return C.l
if(t===Object.prototype)return C.l
if(typeof r=="function"){p=$.dq
if(p==null)p=$.dq=v.getIsolateTag("_$dart_js")
Object.defineProperty(r,p,{value:C.f,enumerable:false,writable:true,configurable:true})
return C.f}return C.f},
em:function(a,b){if(a<0||a>4294967295)throw H.f(P.aU(a,0,4294967295,"length",null))
return J.fv(new Array(a),b)},
fv:function(a,b){return J.en(H.d(a,b.D("w<0>")))},
en:function(a){a.fixed$length=Array
return a},
bg:function(a){if(typeof a=="number"){if(Math.floor(a)==a)return J.aG.prototype
return J.bF.prototype}if(typeof a=="string")return J.a7.prototype
if(a==null)return J.aH.prototype
if(typeof a=="boolean")return J.d_.prototype
if(a.constructor==Array)return J.w.prototype
if(typeof a!="object"){if(typeof a=="function")return J.W.prototype
return a}if(a instanceof P.u)return a
return J.dH(a)},
l:function(a){if(typeof a=="string")return J.a7.prototype
if(a==null)return a
if(a.constructor==Array)return J.w.prototype
if(typeof a!="object"){if(typeof a=="function")return J.W.prototype
return a}if(a instanceof P.u)return a
return J.dH(a)},
bh:function(a){if(a==null)return a
if(a.constructor==Array)return J.w.prototype
if(typeof a!="object"){if(typeof a=="function")return J.W.prototype
return a}if(a instanceof P.u)return a
return J.dH(a)},
hu:function(a){if(typeof a=="string")return J.a7.prototype
if(a==null)return a
if(!(a instanceof P.u))return J.aq.prototype
return a},
cS:function(a){if(a==null)return a
if(typeof a!="object"){if(typeof a=="function")return J.W.prototype
return a}if(a instanceof P.u)return a
return J.dH(a)},
dP:function(a,b){if(a==null)return b==null
if(typeof a!="object")return b!=null&&a===b
return J.bg(a).O(a,b)},
a:function(a,b){if(typeof b==="number")if(a.constructor==Array||typeof a=="string"||H.hE(a,a[v.dispatchPropertyName]))if(b>>>0===b&&b<a.length)return a[b]
return J.l(a).j(a,b)},
fc:function(a,b,c,d){return J.cS(a).be(a,b,c,d)},
fd:function(a){return J.cS(a).aH(a)},
fe:function(a,b){return J.bh(a).l(a,b)},
ff:function(a){return J.bh(a).X(a)},
ed:function(a,b){return J.bh(a).J(a,b)},
fg:function(a){return J.cS(a).gbG(a)},
cT:function(a){return J.bg(a).gm(a)},
bk:function(a){return J.bh(a).gE(a)},
m:function(a){return J.l(a).gk(a)},
ee:function(a){return J.cS(a).bW(a)},
fh:function(a,b,c){return J.bh(a).a3(a,b,c)},
fi:function(a,b){return J.bh(a).aC(a,b)},
fj:function(a){return J.hu(a).c_(a)},
bl:function(a){return J.bg(a).i(a)},
z:function z(){},
d_:function d_(){},
aH:function aH(){},
a8:function a8(){},
bQ:function bQ(){},
aq:function aq(){},
W:function W(){},
w:function w(a){this.$ti=a},
d0:function d0(a){this.$ti=a},
bo:function bo(a,b){var _=this
_.a=a
_.b=b
_.c=0
_.d=null},
aI:function aI(){},
aG:function aG(){},
bF:function bF(){},
a7:function a7(){}},P={
fD:function(){var t,s,r={}
if(self.scheduleImmediate!=null)return P.hq()
if(self.MutationObserver!=null&&self.document!=null){t=self.document.createElement("div")
s=self.document.createElement("span")
r.a=null
new self.MutationObserver(H.bf(new P.dj(r),1)).observe(t,{childList:true})
return new P.di(r,t,s)}else if(self.setImmediate!=null)return P.hr()
return P.hs()},
fE:function(a){self.scheduleImmediate(H.bf(new P.dk(a),0))},
fF:function(a){self.setImmediate(H.bf(new P.dl(a),0))},
fG:function(a){P.fN(0,a)},
fN:function(a,b){var t=new P.dA()
t.bc(a,b)
return t},
he:function(){var t,s
for(t=$.at;t!=null;t=$.at){$.bd=null
s=t.b
$.at=s
if(s==null)$.bc=null
t.a.$0()}},
hk:function(){$.e5=!0
try{P.he()}finally{$.bd=null
$.e5=!1
if($.at!=null)$.ec().$1(P.eS())}},
hi:function(a){var t=new P.c9(a),s=$.bc
if(s==null){$.at=$.bc=t
if(!$.e5)$.ec().$1(P.eS())}else $.bc=s.b=t},
hj:function(a){var t,s,r,q=$.at
if(q==null){P.hi(a)
$.bd=$.bc
return}t=new P.c9(a)
s=$.bd
if(s==null){t.b=q
$.at=$.bd=t}else{r=s.b
t.b=r
$.bd=s.b=t
if(r==null)$.bc=t}},
hf:function(a,b,c,d,e){P.hj(new P.dF(d,e))},
hg:function(a,b,c,d,e){var t,s=$.c7
if(s===c)return d.$1(e)
$.c7=c
t=s
try{s=d.$1(e)
return s}finally{$.c7=t}},
dj:function dj(a){this.a=a},
di:function di(a,b,c){this.a=a
this.b=b
this.c=c},
dk:function dk(a){this.a=a},
dl:function dl(a){this.a=a},
dA:function dA(){},
dB:function dB(a,b){this.a=a
this.b=b},
c9:function c9(a){this.a=a
this.b=null},
bZ:function bZ(){},
dD:function dD(){},
dF:function dF(a,b){this.a=a
this.b=b},
dt:function dt(){},
du:function du(a,b,c){this.a=a
this.b=b
this.c=c},
fw:function(a,b){return new H.aJ(a.D("@<0>").bf(b).D("aJ<1,2>"))},
d2:function(a){return new P.b2(a.D("b2<0>"))},
dY:function(){var t=Object.create(null)
t["<non-identifier-key>"]=t
delete t["<non-identifier-key>"]
return t},
fu:function(a,b,c){var t,s
if(P.e6(a)){if(b==="("&&c===")")return"(...)"
return b+"..."+c}t=H.d([],u.s)
$.H.push(a)
try{P.hd(a,t)}finally{if(0>=$.H.length)return H.k($.H,-1)
$.H.pop()}s=P.et(b,t,", ")+c
return s.charCodeAt(0)==0?s:s},
dT:function(a,b,c){var t,s
if(P.e6(a))return b+"..."+c
t=new P.aX(b)
$.H.push(a)
try{s=t
s.a=P.et(s.a,a,", ")}finally{if(0>=$.H.length)return H.k($.H,-1)
$.H.pop()}t.a+=c
s=t.a
return s.charCodeAt(0)==0?s:s},
e6:function(a){var t,s
for(t=$.H.length,s=0;s<t;++s)if(a===$.H[s])return!0
return!1},
hd:function(a,b){var t,s,r,q,p,o,n,m=a.gE(a),l=0,k=0
while(!0){if(!(l<80||k<3))break
if(!m.q())return
t=H.i(m.gp())
b.push(t)
l+=t.length+2;++k}if(!m.q()){if(k<=5)return
if(0>=b.length)return H.k(b,-1)
s=b.pop()
if(0>=b.length)return H.k(b,-1)
r=b.pop()}else{q=m.gp();++k
if(!m.q()){if(k<=4){b.push(H.i(q))
return}s=H.i(q)
if(0>=b.length)return H.k(b,-1)
r=b.pop()
l+=s.length+2}else{p=m.gp();++k
for(;m.q();q=p,p=o){o=m.gp();++k
if(k>100){while(!0){if(!(l>75&&k>3))break
if(0>=b.length)return H.k(b,-1)
l-=b.pop().length+2;--k}b.push("...")
return}}r=H.i(q)
s=H.i(p)
l+=s.length+r.length+4}}if(k>b.length+2){l+=5
n="..."}else n=null
while(!0){if(!(l>80&&b.length>3))break
if(0>=b.length)return H.k(b,-1)
l-=b.pop().length+2
if(n==null){l+=5
n="..."}}if(n!=null)b.push(n)
b.push(r)
b.push(s)},
eo:function(a,b){var t,s,r=P.d2(b)
for(t=a.length,s=0;s<a.length;a.length===t||(0,H.T)(a),++s)r.l(0,b.a(a[s]))
return r},
ep:function(a){var t,s={}
if(P.e6(a))return"{...}"
t=new P.aX("")
try{$.H.push(a)
t.a+="{"
s.a=!0
a.az(0,new P.d4(s,t))
t.a+="}"}finally{if(0>=$.H.length)return H.k($.H,-1)
$.H.pop()}s=t.a
return s.charCodeAt(0)==0?s:s},
b2:function b2(a){var _=this
_.a=0
_.f=_.e=_.d=_.c=_.b=null
_.r=0
_.$ti=a},
ds:function ds(a){this.a=a
this.b=null},
cw:function cw(a,b){var _=this
_.a=a
_.b=b
_.d=_.c=null},
aM:function aM(){},
F:function F(){},
bL:function bL(){},
d4:function d4(a,b){this.a=a
this.b=b},
a9:function a9(){},
aV:function aV(){},
b5:function b5(){},
b3:function b3(){},
ba:function ba(){},
fs:function(a){if(a instanceof H.a6)return a.i(0)
return"Instance of '"+H.dd(a)+"'"},
fx:function(a,b,c,d){var t,s=J.em(a,d)
if(a!==0&&b!=null)for(t=0;t<a;++t)s[t]=b
return s},
et:function(a,b,c){var t=J.bk(b)
if(!t.q())return a
if(c.length===0){do a+=H.i(t.gp())
while(t.q())}else{a+=H.i(t.gp())
for(;t.q();)a=a+c+H.i(t.gp())}return a},
cZ:function(a){if(typeof a=="number"||H.eN(a)||null==a)return J.bl(a)
if(typeof a=="string")return JSON.stringify(a)
return P.fs(a)},
cU:function(a){return new P.bp(a)},
ef:function(a){return new P.U(!1,null,null,a)},
fA:function(a,b){return new P.aT(null,null,!0,a,b,"Value not in range")},
aU:function(a,b,c,d,e){return new P.aT(b,c,!0,a,d,"Invalid value")},
fB:function(a,b,c){if(0>a||a>c)throw H.f(P.aU(a,0,c,"start",null))
if(a>b||b>c)throw H.f(P.aU(b,a,c,"end",null))
return b},
dW:function(a,b){if(a<0)throw H.f(P.aU(a,0,null,b,null))
return a},
bD:function(a,b,c,d,e){var t=e==null?J.m(b):e
return new P.bC(t,!0,a,c,"Index out of range")},
A:function(a){return new P.c5(a)},
ey:function(a){return new P.c3(a)},
de:function(a){return new P.bX(a)},
aj:function(a){return new P.bt(a)},
q:function q(){},
bp:function bp(a){this.a=a},
c2:function c2(){},
bP:function bP(){},
U:function U(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
aT:function aT(a,b,c,d,e,f){var _=this
_.e=a
_.f=b
_.a=c
_.b=d
_.c=e
_.d=f},
bC:function bC(a,b,c,d,e){var _=this
_.f=a
_.a=b
_.b=c
_.c=d
_.d=e},
c5:function c5(a){this.a=a},
c3:function c3(a){this.a=a},
bX:function bX(a){this.a=a},
bt:function bt(a){this.a=a},
aW:function aW(){},
bu:function bu(a){this.a=a},
dp:function dp(a){this.a=a},
C:function C(){},
bE:function bE(){},
M:function M(){},
u:function u(){},
aX:function aX(a){this.a=a},
o:function o(){},
an:function an(){},
h:function h(){},
ac:function ac(){}},W={
aB:function(a){var t,s,r="element tag unavailable"
try{t=J.cS(a)
t.gaZ(a)
r=t.gaZ(a)}catch(s){H.bj(s)}return r},
dr:function(a,b){a=a+b&536870911
a=a+((a&524287)<<10)&536870911
return a^a>>>6},
eB:function(a,b,c,d){var t=W.dr(W.dr(W.dr(W.dr(0,a),b),c),d),s=t+((t&67108863)<<3)&536870911
s^=s>>>11
return s+((s&16383)<<15)&536870911},
b1:function(a,b,c,d){var t=W.eQ(new W.dn(c),u.z),s=t!=null
if(s&&!0)if(s)J.fc(a,b,t,!1)
return new W.cn(a,b,t,!1)},
eA:function(a){var t=document.createElement("a"),s=new W.dv(t,window.location)
s=new W.as(s)
s.ba(a)
return s},
fH:function(a,b,c,d){return!0},
fI:function(a,b,c,d){var t,s=d.a,r=s.a
r.href=c
t=r.hostname
s=s.b
if(!(t==s.hostname&&r.port===s.port&&r.protocol===s.protocol))if(t==="")if(r.port===""){s=r.protocol
s=s===":"||s===""}else s=!1
else s=!1
else s=!0
return s},
eF:function(){var t=u.N,s=P.eo(C.k,t),r=H.d(["TEMPLATE"],u.s)
t=new W.cK(s,P.d2(t),P.d2(t),P.d2(t),null)
t.bb(null,new H.aO(C.k,new W.dz(),u.e),r,null)
return t},
eQ:function(a,b){var t=$.c7
if(t===C.d)return a
return t.bH(a,b)},
e:function e(){},
bm:function bm(){},
bn:function bn(){},
ah:function ah(){},
a5:function a5(){},
Q:function Q(){},
ax:function ax(){},
cX:function cX(){},
cY:function cY(){},
az:function az(){},
v:function v(){},
c:function c(){},
by:function by(){},
bA:function bA(){},
d3:function d3(){},
K:function K(){},
ca:function ca(a){this.a=a},
j:function j(){},
aP:function aP(){},
bW:function bW(){},
ao:function ao(){},
P:function P(){},
a1:function a1(){},
b_:function b_(){},
ar:function ar(){},
b0:function b0(){},
b4:function b4(){},
dm:function dm(){},
ch:function ch(a){this.a=a},
dS:function dS(a,b){this.a=a
this.$ti=b},
cn:function cn(a,b,c,d){var _=this
_.b=a
_.c=b
_.d=c
_.e=d},
dn:function dn(a){this.a=a},
as:function as(a){this.a=a},
aF:function aF(){},
aQ:function aQ(a){this.a=a},
d7:function d7(a){this.a=a},
d6:function d6(a,b,c){this.a=a
this.b=b
this.c=c},
b6:function b6(){},
dw:function dw(){},
dx:function dx(){},
cK:function cK(a,b,c,d,e){var _=this
_.e=a
_.a=b
_.b=c
_.c=d
_.d=e},
dz:function dz(){},
cJ:function cJ(){},
aC:function aC(a,b){var _=this
_.a=a
_.b=b
_.c=-1
_.d=null},
cM:function cM(){},
dv:function dv(a,b){this.a=a
this.b=b},
cP:function cP(a){this.a=a
this.b=0},
dC:function dC(a){this.a=a},
cf:function cf(){},
cx:function cx(){},
cy:function cy(){},
cQ:function cQ(){},
cR:function cR(){}},V={al:function al(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},d5:function d5(a,b,c,d,e,f){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f
_.r=!1}},D={bM:function bM(a,b){this.a=a
this.b=b},bN:function bN(a,b){this.a=a
this.b=b},bO:function bO(a,b,c,d,e,f,g,h,i){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f
_.r=g
_.x=h
_.y=i}},O={dc:function dc(){}},Y={
ft:function(a){return new Y.aE(H.d([],u.m),H.d([],u.E),!0)},
aa:function aa(a,b,c,d,e,f){var _=this
_.f=a
_.r=b
_.x=c
_.b=!0
_.c=d
_.a$=e
_.b$=f},
bq:function bq(a,b,c,d){var _=this
_.a=a
_.c$=b
_.a$=c
_.b$=d},
br:function br(a,b,c){this.c$=a
this.a$=b
this.b$=c},
bw:function bw(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c$=c
_.a$=d
_.b$=e},
bx:function bx(a,b,c){this.c$=a
this.a$=b
this.b$=c},
bI:function bI(a,b,c){this.c$=a
this.a$=b
this.b$=c},
bJ:function bJ(a,b,c){this.c$=a
this.a$=b
this.b$=c},
bS:function bS(a,b,c){this.c$=a
this.a$=b
this.b$=c},
bR:function bR(a,b,c){this.c$=a
this.a$=b
this.b$=c},
bT:function bT(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c$=c
_.a$=d
_.b$=e},
bU:function bU(a,b,c){this.c$=a
this.a$=b
this.b$=c},
bv:function bv(a,b){this.a$=a
this.b$=b},
bB:function bB(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.a$=d
_.b$=e},
c0:function c0(a,b,c,d,e,f,g){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.a$=f
_.b$=g},
aE:function aE(a,b,c){var _=this
_.b=!0
_.c=a
_.a$=b
_.b$=c},
cb:function cb(){},
cc:function cc(){},
cd:function cd(){},
ce:function ce(){},
cg:function cg(){},
ci:function ci(){},
cj:function cj(){},
ck:function ck(){},
cl:function cl(){},
cp:function cp(){},
cq:function cq(){},
cs:function cs(){},
ct:function ct(){},
cu:function cu(){},
cv:function cv(){},
cA:function cA(){},
cB:function cB(){},
cC:function cC(){},
cD:function cD(){},
cE:function cE(){},
cF:function cF(){},
cG:function cG(){},
cH:function cH(){},
cL:function cL(){}},N={ay:function ay(a){this.a=a
this.b=!1},bs:function bs(a){this.a=a
this.b=null},x:function x(a){this.a=a
this.b=null},bz:function bz(a){this.a=a
this.b=null},ab:function ab(a){this.a=a
this.b=0},c1:function c1(a){this.a=a
this.c=null},B:function B(){},J:function J(){},cV:function cV(a){this.a=a}},T={
y:function(){return new T.a_(!0,0,0,0,0)},
ew:function(){return new T.ap(1,1,0,0)},
b:function(a){if(a>1)return 1
else if(a<0)return 0
else return a},
a_:function a_(a,b,c,d,e){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e},
ap:function ap(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
p:function p(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d}},Q={
fy:function(a,b){var t=document.createElementNS("http://www.w3.org/2000/svg","svg")
u.u.a(t)
t.setAttribute("version","1.1")
t=new Q.am(a,u.v.a(t),b)
t.b9(a,b)
return t},
hJ:function(a){return new Q.dy(null,C.w,a)},
am:function am(a,b,c){var _=this
_.a=a
_.b=b
_.c=c
_.d=null
_.e=!1},
d9:function d9(a){this.a=a},
da:function da(a){this.a=a},
db:function db(a){this.a=a},
dy:function dy(a,b,c){this.a=a
this.b=b
this.c=c}},K={df:function df(a,b,c,d,e){var _=this
_.a=a
_.b=null
_.c=b
_.d=null
_.e=0
_.f=c
_.Q=_.z=_.y=_.x=_.r=null
_.ch="Verdana"
_.cx=!1
_.cy=d
_.db=e}},F={
hH:function(){var t,s,r,q,p,o,n,m,l,k=-100,j=-200,i=T.y(),h=T.ew(),g=H.d([],u.R),f=u.m,e=u.E,d=new Y.aa(i,h,g,H.d([],f),H.d([],e),!0)
g.push(new D.bO(h,d.gb1(),!0,C.D,0,0,0,0,!1))
t=new Y.bB(new T.p(T.b(0.9),T.b(0.9),T.b(1),T.b(1)),new T.p(T.b(0.5),T.b(0.5),T.b(1),T.b(1)),new T.p(T.b(1),T.b(0.7),T.b(0.7),T.b(1)),H.d([],e),!0)
t.u(0,0,0)
s=new Y.bv(H.d([],e),!0)
s.u(1,0.75,0.75)
d.A(H.d([t,s],f))
d.u(0,0,0)
r=F.G(d,0,0,"Circle Group")
q=u.n
r.aO(1.5,H.d([10,20,20,40,30,60],q))
p=r.aO(3.5,H.d([30,20,40,40,50,60],q))
p.u(1,1,1)
p.a$.push(new N.x(new T.p(T.b(0),T.b(0),T.b(1),T.b(1))))
r=F.G(d,100,0,"Circles")
r.aP(H.d([10,20,1,20,40,3,30,60,5],q))
p=r.aP(H.d([30,20,2.5,40,40,4.5,50,60,6.5],q))
p.u(0,0,1)
p.a$.push(new N.x(new T.p(T.b(0),T.b(1),T.b(0),T.b(1))))
r=F.G(d,200,0,"Ellipse Group")
r.aQ(4,2,H.d([10,20,20,40,30,60],q))
p=r.aQ(4,8,H.d([30,20,40,40,50,60],q))
p.u(0,0,1)
p.a$.push(new N.x(new T.p(T.b(0),T.b(1),T.b(0),T.b(1))))
r=F.G(d,300,0,"Ellipses")
r.aR(H.d([10,20,4,2,20,40,3,3,30,60,2,4],q))
p=r.aR(H.d([30,20,4,8,40,40,6,6,50,60,8,4],q))
p.u(0,0,1)
p.a$.push(new N.x(new T.p(T.b(0),T.b(1),T.b(0),T.b(1))))
r=F.G(d,0,k,"Line Strip")
p=H.d([20,20,30,45,50,55,55,45.5,20,60,60,20],q)
o=new Y.bI(null,H.d([],e),!0)
o.l(0,p)
r.A(H.d([o],f))
F.G(d,100,k,"Lines").W(H.d([20,20,30,45,50,55,55,45.5,20,60,60,20],q))
F.G(d,200,k,"Directed Lines").W(H.d([20,20,30,45,50,55,55,45.5,20,60,60,20],q)).a$.push(new N.ay(!0))
F.G(d,300,k,"Pointed Lines").W(H.d([20,20,30,45,50,55,55,45.5,20,60,60,20],q)).a$.push(new N.ab(3))
F.G(d,0,j,"Points").as(H.d([20,20,30,45,50,55,55,45.5,20,60,60,20],q)).a$.push(new N.ab(3))
F.G(d,0,j,"Points").as(H.d([20,20,30,45,50,55,55,45.5,20,60,60,20],q)).a$.push(new N.ab(3))
r=F.G(d,100,j,"Polygon")
p=H.d([20,20,30,45,50,55,55,45.5,20,60,60,20],q)
e=H.d([],e)
o=new Y.bS(null,e,!0)
o.l(0,p)
r.A(H.d([o],f))
e.push(new N.x(new T.p(T.b(0),T.b(0),T.b(1),T.b(0.5))))
r=F.G(d,200,j,"Rectangle Group")
r.aS(8,4,H.d([10,20,20,40,30,60],q))
e=r.aS(8,16,H.d([30,20,40,40,50,60],q))
e.u(0,0,1)
e.a$.push(new N.x(new T.p(T.b(0),T.b(1),T.b(0),T.b(1))))
r=F.G(d,300,j,"Rectangles")
r.a6(H.d([10,20,8,4,20,40,6,6,30,60,4,8],q))
e=r.a6(H.d([30,20,8,16,40,40,12,12,50,60,16,8],q))
e.u(0,0,1)
e.a$.push(new N.x(new T.p(T.b(0),T.b(1),T.b(0),T.b(1))))
r=F.G(d,0,-300,"Text")
r.H(10,70,4,"Small",!0)
r.H(10,60,6,"Courier",!0).a$.push(new N.bz("Courier"))
e=r.H(10,50,6,"Colored",!0)
e.u(1,0,0)
e.a$.push(new N.x(new T.p(T.b(0),T.b(0),T.b(1),T.b(1))))
e=r.H(10,30,16,"Large",!0)
e.u(0,0,0)
e.a$.push(new N.x(new T.p(T.b(1),T.b(1),T.b(1),T.b(0.5))))
r=F.G(d,100,-300,"Mouse Examples")
r.H(10,70,6,"Hold shift while clicking",!0).a$.push(new N.x(new T.p(T.b(0),T.b(0),T.b(0),T.b(1))))
r.H(20,60,6,"to add red points.",!0).a$.push(new N.x(new T.p(T.b(0),T.b(0),T.b(0),T.b(1))))
r.H(10,40,6,"Hold ctrl while clicking",!0).a$.push(new N.x(new T.p(T.b(0),T.b(0),T.b(0),T.b(1))))
r.H(20,30,6,"to add red arrows.",!0).a$.push(new N.x(new T.p(T.b(0),T.b(0),T.b(0),T.b(1))))
e=d.f=d.v(h)
h.b=h.a=1
h.d=h.c=0
if(!e.a){f=e.d
p=e.b
n=e.e
e=e.c
m=h.b=h.a=0.95/Math.max(f-p,n-e)
h.c=-0.5*(p+f)*m
h.d=-0.5*(e+n)*m}f=d.as(H.d([],q))
f.a$.push(new N.ab(4))
f.u(1,0,0)
g.push(new F.cz(f))
f=d.W(H.d([],q))
f.a$.push(new N.ay(!0))
f.u(1,0,0)
g.push(new F.c8(f))
g.push(new D.bM(d,d.bD(0,0,12,"")))
l=d.W(H.d([],q))
l.u(1,0,0)
g.push(new D.bN(d,l))
new F.dN().$1(d)},
G:function(a,b,c,d){var t,s,r=Y.ft("")
r.b=!0
a.A(H.d([r],u.m))
t=r.a$
t.push(new N.c1(new T.ap(1,1,b,c)))
s=u.n
r.a6(H.d([0,10,90,80],s))
r.a6(H.d([0,90,90,10],s)).a$.push(new N.x(new T.p(T.b(0),T.b(0),T.b(0),T.b(0.75))))
r.H(5,92,8,d,!0)
r.u(0.7,0.7,0.7)
t.push(new N.x(new T.p(T.b(1),T.b(1),T.b(1),T.b(1))))
return r},
dN:function dN(){},
c8:function c8(a){this.a=!1
this.b=a},
cz:function cz(a){this.a=a
this.b=!1}}
var w=[C,H,J,P,W,V,D,O,Y,N,T,Q,K,F]
hunkHelpers.setFunctionNamesIfNecessary(w)
var $={}
H.dU.prototype={}
J.z.prototype={
O:function(a,b){return a===b},
gm:function(a){return H.aS(a)},
i:function(a){return"Instance of '"+H.dd(a)+"'"}}
J.d_.prototype={
i:function(a){return String(a)},
gm:function(a){return a?519018:218159}}
J.aH.prototype={
O:function(a,b){return null==b},
i:function(a){return"null"},
gm:function(a){return 0}}
J.a8.prototype={
gm:function(a){return 0},
i:function(a){return String(a)}}
J.bQ.prototype={}
J.aq.prototype={}
J.W.prototype={
i:function(a){var t=a[$.f0()]
if(t==null)return this.b7(a)
return"JavaScript function for "+J.bl(t)},
$iaD:1}
J.w.prototype={
l:function(a,b){if(!!a.fixed$length)H.ag(P.A("add"))
a.push(b)},
a3:function(a,b,c){var t,s
if(!!a.immutable$list)H.ag(P.A("setAll"))
t=a.length
if(b<0||b>t)H.ag(P.aU(b,0,t,"index",null))
for(t=J.bk(c);t.q();b=s){s=b+1
this.G(a,b,t.gp())}},
X:function(a){this.sk(a,0)},
aC:function(a,b){return H.eu(a,b,null,H.dE(a).c)},
J:function(a,b){if(b<0||b>=a.length)return H.k(a,b)
return a[b]},
aT:function(a,b){var t,s=a.length
for(t=0;t<s;++t){if(b.$1(a[t]))return!0
if(a.length!==s)throw H.f(P.aj(a))}return!1},
B:function(a,b){var t
for(t=0;t<a.length;++t)if(J.dP(a[t],b))return!0
return!1},
i:function(a){return P.dT(a,"[","]")},
gE:function(a){return new J.bo(a,a.length)},
gm:function(a){return H.aS(a)},
gk:function(a){return a.length},
sk:function(a,b){if(!!a.fixed$length)H.ag(P.A("set length"))
if(b>a.length)H.dE(a).c.a(null)
a.length=b},
j:function(a,b){if(b>=a.length||b<0)throw H.f(H.e9(a,b))
return a[b]},
G:function(a,b,c){if(!!a.immutable$list)H.ag(P.A("indexed set"))
if(b>=a.length||b<0)throw H.f(H.e9(a,b))
a[b]=c},
$iD:1}
J.d0.prototype={}
J.bo.prototype={
gp:function(){return H.ad(this).c.a(this.d)},
q:function(){var t,s=this,r=s.a,q=r.length
if(s.b!==q)throw H.f(H.T(r))
t=s.c
if(t>=q){s.d=null
return!1}s.d=r[t]
s.c=t+1
return!0}}
J.aI.prototype={
a7:function(a){var t,s
if(a>=0){if(a<=2147483647){t=a|0
return a===t?t:t+1}}else if(a>=-2147483648)return a|0
s=Math.ceil(a)
if(isFinite(s))return s
throw H.f(P.A(""+a+".ceil()"))},
ay:function(a){var t,s
if(a>=0){if(a<=2147483647)return a|0}else if(a>=-2147483648){t=a|0
return a===t?t:t-1}s=Math.floor(a)
if(isFinite(s))return s
throw H.f(P.A(""+a+".floor()"))},
b_:function(a,b){var t,s
if(b<1||b>21)throw H.f(P.aU(b,1,21,"precision",null))
t=a.toPrecision(b)
if(a===0)s=1/a<0
else s=!1
if(s)return"-"+t
return t},
i:function(a){if(a===0&&1/a<0)return"-0.0"
else return""+a},
gm:function(a){var t,s,r,q,p=a|0
if(a===p)return p&536870911
t=Math.abs(a)
s=Math.log(t)/0.6931471805599453|0
r=Math.pow(2,s)
q=t<1?t/r:r/t
return((q*9007199254740992|0)+(q*3542243181176521|0))*599197+s*1259&536870911},
bA:function(a,b){var t
if(a>0)t=this.bz(a,b)
else{t=b>31?31:b
t=a>>t>>>0}return t},
bz:function(a,b){return b>31?0:a>>>b},
$iI:1,
$iS:1}
J.aG.prototype={}
J.bF.prototype={}
J.a7.prototype={
N:function(a,b){return a+b},
b4:function(a,b){var t=b.length
if(t>a.length)return!1
return b===a.substring(0,t)},
c_:function(a){return a.toLowerCase()},
i:function(a){return a},
gm:function(a){var t,s,r
for(t=a.length,s=0,r=0;r<t;++r){s=s+a.charCodeAt(r)&536870911
s=s+((s&524287)<<10)&536870911
s^=s>>6}s=s+((s&67108863)<<3)&536870911
s^=s>>11
return s+((s&16383)<<15)&536870911},
gk:function(a){return a.length},
$ir:1}
H.aK.prototype={
i:function(a){var t="LateInitializationError: "+this.a
return t}}
H.aA.prototype={}
H.ak.prototype={
gE:function(a){return new H.aN(this,this.gk(this))},
a8:function(a,b){return this.b6(0,b)}}
H.aY.prototype={
gbj:function(){var t=J.m(this.a)
return t},
gbB:function(){var t=J.m(this.a),s=this.b
if(s>t)return t
return s},
gk:function(a){var t=J.m(this.a),s=this.b
if(s>=t)return 0
return t-s},
J:function(a,b){var t=this,s=t.gbB()+b
if(b<0||s>=t.gbj())throw H.f(P.bD(b,t,"index",null,null))
return J.ed(t.a,s)},
bZ:function(a,b){var t,s,r,q=this,p=q.b,o=q.a,n=J.l(o),m=n.gk(o),l=m-p
if(l<=0){o=J.em(0,q.$ti.c)
return o}t=P.fx(l,n.J(o,p),!1,q.$ti.c)
for(s=1;s<l;++s){r=n.J(o,p+s)
if(s>=t.length)return H.k(t,s)
t[s]=r
if(n.gk(o)<m)throw H.f(P.aj(q))}return t}}
H.aN.prototype={
gp:function(){return H.ad(this).c.a(this.d)},
q:function(){var t,s=this,r=s.a,q=J.l(r),p=q.gk(r)
if(s.b!==p)throw H.f(P.aj(r))
t=s.c
if(t>=p){s.d=null
return!1}s.d=q.J(r,t);++s.c
return!0}}
H.aO.prototype={
gk:function(a){return J.m(this.a)},
J:function(a,b){return this.b.$1(J.ed(this.a,b))}}
H.aZ.prototype={
gE:function(a){return new H.c6(J.bk(this.a),this.b)}}
H.c6.prototype={
q:function(){var t,s
for(t=this.a,s=this.b;t.q();)if(s.$1(t.gp()))return!0
return!1},
gp:function(){return this.a.gp()}}
H.dg.prototype={
K:function(a){var t,s,r=this,q=new RegExp(r.a).exec(a)
if(q==null)return null
t=Object.create(null)
s=r.b
if(s!==-1)t.arguments=q[s+1]
s=r.c
if(s!==-1)t.argumentsExpr=q[s+1]
s=r.d
if(s!==-1)t.expr=q[s+1]
s=r.e
if(s!==-1)t.method=q[s+1]
s=r.f
if(s!==-1)t.receiver=q[s+1]
return t}}
H.aR.prototype={
i:function(a){var t=this.b
if(t==null)return"NoSuchMethodError: "+this.a
return"NoSuchMethodError: method not found: '"+t+"' on null"}}
H.bH.prototype={
i:function(a){var t,s=this,r="NoSuchMethodError: method not found: '",q=s.b
if(q==null)return"NoSuchMethodError: "+s.a
t=s.c
if(t==null)return r+q+"' ("+s.a+")"
return r+q+"' on '"+t+"' ("+s.a+")"}}
H.c4.prototype={
i:function(a){var t=this.a
return t.length===0?"Error":"Error: "+t}}
H.d8.prototype={
i:function(a){return"Throw of null ('"+(this.a===null?"null":"undefined")+"' from JavaScript)"}}
H.cI.prototype={
i:function(a){var t,s=this.b
if(s!=null)return s
s=this.a
t=s!==null&&typeof s==="object"?s.stack:null
return this.b=t==null?"":t}}
H.a6.prototype={
i:function(a){var t=this.constructor,s=t==null?null:t.name
return"Closure '"+H.f_(s==null?"unknown":s)+"'"},
$iaD:1,
gc1:function(){return this},
$C:"$1",
$R:1,
$D:null}
H.c_.prototype={}
H.bY.prototype={
i:function(a){var t=this.$static_name
if(t==null)return"Closure of unknown static method"
return"Closure '"+H.f_(t)+"'"}}
H.ai.prototype={
O:function(a,b){var t=this
if(b==null)return!1
if(t===b)return!0
if(!(b instanceof H.ai))return!1
return t.a===b.a&&t.b===b.b&&t.c===b.c},
gm:function(a){var t,s=this.c
if(s==null)t=H.aS(this.a)
else t=typeof s!=="object"?J.cT(s):H.aS(s)
return(t^H.aS(this.b))>>>0},
i:function(a){var t=this.c
if(t==null)t=this.a
return"Closure '"+H.i(this.d)+"' of "+("Instance of '"+H.dd(t)+"'")}}
H.bV.prototype={
i:function(a){return"RuntimeError: "+this.a}}
H.aJ.prototype={
gk:function(a){return this.a},
gM:function(){return new H.aL(this,H.ad(this).D("aL<1>"))},
j:function(a,b){var t,s,r,q,p=this,o=null
if(typeof b=="string"){t=p.b
if(t==null)return o
s=p.ah(t,b)
r=s==null?o:s.b
return r}else if(typeof b=="number"&&(b&0x3ffffff)===b){q=p.c
if(q==null)return o
s=p.ah(q,b)
r=s==null?o:s.b
return r}else return p.bT(b)},
bT:function(a){var t,s,r=this.d
if(r==null)return null
t=this.aL(r,J.cT(a)&0x3ffffff)
s=this.aW(t,a)
if(s<0)return null
return t[s].b},
G:function(a,b,c){var t,s,r,q,p,o,n=this
if(typeof b=="string"){t=n.b
n.aD(t==null?n.b=n.ak():t,b,c)}else if(typeof b=="number"&&(b&0x3ffffff)===b){s=n.c
n.aD(s==null?n.c=n.ak():s,b,c)}else{r=n.d
if(r==null)r=n.d=n.ak()
q=J.cT(b)&0x3ffffff
p=n.aL(r,q)
if(p==null)n.ao(r,q,[n.ab(b,c)])
else{o=n.aW(p,b)
if(o>=0)p[o].b=c
else p.push(n.ab(b,c))}}},
az:function(a,b){var t=this,s=t.e,r=t.r
for(;s!=null;){b.$2(s.a,s.b)
if(r!==t.r)throw H.f(P.aj(t))
s=s.c}},
aD:function(a,b,c){var t=this.ah(a,b)
if(t==null)this.ao(a,b,this.ab(b,c))
else t.b=c},
bl:function(){this.r=this.r+1&67108863},
ab:function(a,b){var t,s=this,r=new H.d1(a,b)
if(s.e==null)s.e=s.f=r
else{t=s.f
t.toString
r.d=t
s.f=t.c=r}++s.a
s.bl()
return r},
aW:function(a,b){var t,s
if(a==null)return-1
t=a.length
for(s=0;s<t;++s)if(J.dP(a[s].a,b))return s
return-1},
i:function(a){return P.ep(this)},
ah:function(a,b){return a[b]},
aL:function(a,b){return a[b]},
ao:function(a,b,c){a[b]=c},
bh:function(a,b){delete a[b]},
ak:function(){var t="<non-identifier-key>",s=Object.create(null)
this.ao(s,t,s)
this.bh(s,t)
return s}}
H.d1.prototype={}
H.aL.prototype={
gk:function(a){return this.a.a},
gE:function(a){var t=this.a,s=new H.bK(t,t.r)
s.c=t.e
return s}}
H.bK.prototype={
gp:function(){return H.ad(this).c.a(this.d)},
q:function(){var t,s=this,r=s.a
if(s.b!==r.r)throw H.f(P.aj(r))
t=s.c
if(t==null){s.d=null
return!1}else{s.d=t.a
s.c=t.c
return!0}}}
H.dJ.prototype={
$1:function(a){return this.a(a)},
$S:8}
H.dK.prototype={
$2:function(a,b){return this.a(a,b)},
$S:9}
H.dL.prototype={
$1:function(a){return this.a(a)},
$S:10}
H.O.prototype={
D:function(a){return H.cO(v.typeUniverse,this,a)},
bf:function(a){return H.fX(v.typeUniverse,this,a)}}
H.co.prototype={}
H.cm.prototype={
i:function(a){return this.a}}
H.b7.prototype={}
P.dj.prototype={
$1:function(a){var t=this.a,s=t.a
t.a=null
s.$0()},
$S:11}
P.di.prototype={
$1:function(a){var t,s
this.a.a=a
t=this.b
s=this.c
t.firstChild?t.removeChild(s):t.appendChild(s)},
$S:12}
P.dk.prototype={
$0:function(){this.a.$0()},
$S:3}
P.dl.prototype={
$0:function(){this.a.$0()},
$S:3}
P.dA.prototype={
bc:function(a,b){if(self.setTimeout!=null)self.setTimeout(H.bf(new P.dB(this,b),0),a)
else throw H.f(P.A("`setTimeout()` not found."))}}
P.dB.prototype={
$0:function(){this.b.$0()},
$S:0}
P.c9.prototype={}
P.bZ.prototype={}
P.dD.prototype={}
P.dF.prototype={
$0:function(){var t=H.f(this.a)
t.stack=this.b.i(0)
throw t},
$S:0}
P.dt.prototype={
bX:function(a,b){var t,s,r,q=null
try{if(C.d===$.c7){a.$1(b)
return}P.hg(q,q,this,a,b)}catch(r){t=H.bj(r)
s=H.hw(r)
P.hf(q,q,this,t,s)}},
bY:function(a,b){return this.bX(a,b,u.D)},
bH:function(a,b){return new P.du(this,a,b)}}
P.du.prototype={
$1:function(a){return this.a.bY(this.b,a)},
$S:function(){return this.c.D("~(0)")}}
P.b2.prototype={
gE:function(a){var t=new P.cw(this,this.r)
t.c=this.e
return t},
gk:function(a){return this.a},
B:function(a,b){var t,s
if(b!=="__proto__"){t=this.b
if(t==null)return!1
return t[b]!=null}else{s=this.bg(b)
return s}},
bg:function(a){var t=this.d
if(t==null)return!1
return this.aK(t[this.aI(a)],a)>=0},
l:function(a,b){var t,s,r=this
if(typeof b=="string"&&b!=="__proto__"){t=r.b
return r.aE(t==null?r.b=P.dY():t,b)}else if(typeof b=="number"&&(b&1073741823)===b){s=r.c
return r.aE(s==null?r.c=P.dY():s,b)}else return r.bd(b)},
bd:function(a){var t,s,r=this,q=r.d
if(q==null)q=r.d=P.dY()
t=r.aI(a)
s=q[t]
if(s==null)q[t]=[r.al(a)]
else{if(r.aK(s,a)>=0)return!1
s.push(r.al(a))}return!0},
aE:function(a,b){if(a[b]!=null)return!1
a[b]=this.al(b)
return!0},
al:function(a){var t=this,s=new P.ds(a)
if(t.e==null)t.e=t.f=s
else t.f=t.f.b=s;++t.a
t.r=t.r+1&1073741823
return s},
aI:function(a){return J.cT(a)&1073741823},
aK:function(a,b){var t,s
if(a==null)return-1
t=a.length
for(s=0;s<t;++s)if(J.dP(a[s].a,b))return s
return-1}}
P.ds.prototype={}
P.cw.prototype={
gp:function(){return H.ad(this).c.a(this.d)},
q:function(){var t=this,s=t.c,r=t.a
if(t.b!==r.r)throw H.f(P.aj(r))
else if(s==null){t.d=null
return!1}else{t.d=s.a
t.c=s.b
return!0}}}
P.aM.prototype={$iD:1}
P.F.prototype={
gE:function(a){return new H.aN(a,this.gk(a))},
J:function(a,b){return this.j(a,b)},
aC:function(a,b){return H.eu(a,b,null,H.ae(a).D("F.E"))},
l:function(a,b){var t=this.gk(a)
this.sk(a,t+1)
this.G(a,t,b)},
X:function(a){this.sk(a,0)},
aa:function(a,b,c,d){var t,s,r,q
P.fB(b,c,this.gk(a))
t=c-b
if(t===0)return
P.dW(0,"skipCount")
s=H.ae(a).D("D<F.E>").b(d)?d:J.fi(d,0).bZ(0,!1)
r=J.l(s)
if(t>r.gk(s))throw H.f(P.de("Too few elements"))
if(0<b)for(q=t-1;q>=0;--q)this.G(a,b+q,r.j(s,q))
else for(q=0;q<t;++q)this.G(a,b+q,r.j(s,q))},
a3:function(a,b,c){this.aa(a,b,b+J.m(c),c)},
i:function(a){return P.dT(a,"[","]")}}
P.bL.prototype={}
P.d4.prototype={
$2:function(a,b){var t,s=this.a
if(!s.a)this.b.a+=", "
s.a=!1
s=this.b
t=s.a+=H.i(a)
s.a=t+": "
s.a+=H.i(b)},
$S:13}
P.a9.prototype={
az:function(a,b){var t,s,r
for(t=J.bk(this.gM()),s=H.ad(this).D("a9.V");t.q();){r=t.gp()
b.$2(r,s.a(this.j(0,r)))}},
gk:function(a){return J.m(this.gM())},
i:function(a){return P.ep(this)}}
P.aV.prototype={
a5:function(a,b){var t
for(t=J.bk(b);t.q();)this.l(0,t.gp())},
i:function(a){return P.dT(this,"{","}")}}
P.b5.prototype={}
P.b3.prototype={}
P.ba.prototype={}
P.q.prototype={}
P.bp.prototype={
i:function(a){var t=this.a
if(t!=null)return"Assertion failed: "+P.cZ(t)
return"Assertion failed"}}
P.c2.prototype={}
P.bP.prototype={
i:function(a){return"Throw of null."}}
P.U.prototype={
gae:function(){return"Invalid argument"+(!this.a?"(s)":"")},
gad:function(){return""},
i:function(a){var t,s,r=this,q=r.c,p=q==null?"":" ("+q+")",o=r.d,n=o==null?"":": "+o,m=r.gae()+p+n
if(!r.a)return m
t=r.gad()
s=P.cZ(r.b)
return m+t+": "+s}}
P.aT.prototype={
gae:function(){return"RangeError"},
gad:function(){var t,s=this.e,r=this.f
if(s==null)t=r!=null?": Not less than or equal to "+H.i(r):""
else if(r==null)t=": Not greater than or equal to "+H.i(s)
else if(r>s)t=": Not in inclusive range "+H.i(s)+".."+H.i(r)
else t=r<s?": Valid value range is empty":": Only valid value is "+H.i(s)
return t}}
P.bC.prototype={
gae:function(){return"RangeError"},
gad:function(){if(this.b<0)return": index must not be negative"
var t=this.f
if(t===0)return": no indices are valid"
return": index should be less than "+t},
gk:function(a){return this.f}}
P.c5.prototype={
i:function(a){return"Unsupported operation: "+this.a}}
P.c3.prototype={
i:function(a){var t="UnimplementedError: "+this.a
return t}}
P.bX.prototype={
i:function(a){return"Bad state: "+this.a}}
P.bt.prototype={
i:function(a){var t=this.a
if(t==null)return"Concurrent modification during iteration."
return"Concurrent modification during iteration: "+P.cZ(t)+"."}}
P.aW.prototype={
i:function(a){return"Stack Overflow"},
$iq:1}
P.bu.prototype={
i:function(a){var t="Reading static variable '"+this.a+"' during its initialization"
return t}}
P.dp.prototype={
i:function(a){return"Exception: "+this.a}}
P.C.prototype={
a8:function(a,b){return new H.aZ(this,b,H.ad(this).D("aZ<C.E>"))},
gk:function(a){var t,s=this.gE(this)
for(t=0;s.q();)++t
return t},
J:function(a,b){var t,s,r
P.dW(b,"index")
for(t=this.gE(this),s=0;t.q();){r=t.gp()
if(b===s)return r;++s}throw H.f(P.bD(b,this,"index",null,s))},
i:function(a){return P.fu(this,"(",")")}}
P.bE.prototype={}
P.M.prototype={
gm:function(a){return P.u.prototype.gm.call(C.y,this)},
i:function(a){return"null"}}
P.u.prototype={constructor:P.u,$iu:1,
O:function(a,b){return this===b},
gm:function(a){return H.aS(this)},
i:function(a){return"Instance of '"+H.dd(this)+"'"},
toString:function(){return this.i(this)}}
P.aX.prototype={
gk:function(a){return this.a.length},
i:function(a){var t=this.a
return t.charCodeAt(0)==0?t:t}}
W.e.prototype={}
W.bm.prototype={
i:function(a){return String(a)}}
W.bn.prototype={
i:function(a){return String(a)}}
W.ah.prototype={$iah:1}
W.a5.prototype={$ia5:1}
W.Q.prototype={
gk:function(a){return a.length}}
W.ax.prototype={
gk:function(a){return a.length}}
W.cX.prototype={}
W.cY.prototype={
i:function(a){return String(a)}}
W.az.prototype={
i:function(a){var t,s=a.left
s.toString
s="Rectangle ("+H.i(s)+", "
t=a.top
t.toString
t=s+H.i(t)+") "
s=a.width
s.toString
s=t+H.i(s)+" x "
t=a.height
t.toString
return s+H.i(t)},
O:function(a,b){var t,s
if(b==null)return!1
if(u.q.b(b)){t=a.left
t.toString
s=b.left
s.toString
if(t===s){t=a.top
t.toString
s=b.top
s.toString
if(t===s){t=a.width
t.toString
s=b.width
s.toString
if(t===s){t=a.height
t.toString
s=b.height
s.toString
s=t===s
t=s}else t=!1}else t=!1}else t=!1}else t=!1
return t},
gm:function(a){var t,s,r,q=a.left
q.toString
q=C.a.gm(q)
t=a.top
t.toString
t=C.a.gm(t)
s=a.width
s.toString
s=C.a.gm(s)
r=a.height
r.toString
return W.eB(q,t,s,C.a.gm(r))},
$idX:1}
W.v.prototype={
gbG:function(a){return new W.ch(a)},
i:function(a){return a.localName},
at:function(a,b,c,d){var t,s,r,q
if(c==null){if(d==null){t=$.ek
if(t==null){t=H.d([],u.Q)
s=new W.aQ(t)
t.push(W.eA(null))
t.push(W.eF())
$.ek=s
d=s}else d=t}t=$.ej
if(t==null){t=new W.cP(d)
$.ej=t
c=t}else{t.a=d
c=t}}else if(d!=null)throw H.f(P.ef("validator can only be passed if treeSanitizer is null"))
if($.a0==null){t=document
s=t.implementation.createHTMLDocument("")
$.a0=s
$.dR=s.createRange()
s=$.a0.createElement("base")
u.y.a(s)
t=t.baseURI
t.toString
s.href=t
$.a0.head.appendChild(s)}t=$.a0
if(t.body==null){s=t.createElement("body")
t.body=u.t.a(s)}t=$.a0
if(u.t.b(a)){t=t.body
t.toString
r=t}else{t.toString
r=t.createElement(a.tagName)
$.a0.body.appendChild(r)}if("createContextualFragment" in window.Range.prototype&&!C.c.B(C.B,a.tagName)){$.dR.selectNodeContents(r)
t=$.dR
q=t.createContextualFragment(b)}else{r.innerHTML=b
q=$.a0.createDocumentFragment()
for(;t=r.firstChild,t!=null;)q.appendChild(t)}if(r!==$.a0.body)J.ee(r)
c.a9(q)
document.adoptNode(q)
return q},
bI:function(a,b,c){return this.at(a,b,c,null)},
gaZ:function(a){return a.tagName},
$iv:1}
W.c.prototype={$ic:1}
W.by.prototype={
be:function(a,b,c,d){return a.addEventListener(b,H.bf(c,1),!1)}}
W.bA.prototype={
gk:function(a){return a.length}}
W.d3.prototype={
i:function(a){return String(a)}}
W.K.prototype={$iK:1}
W.ca.prototype={
gb3:function(a){var t=this.a,s=t.childNodes.length
if(s===0)throw H.f(P.de("No elements"))
if(s>1)throw H.f(P.de("More than one element"))
t=t.firstChild
t.toString
return t},
l:function(a,b){this.a.appendChild(b)},
a3:function(a,b,c){throw H.f(P.A("Cannot setAll on Node list"))},
X:function(a){J.fd(this.a)},
G:function(a,b,c){var t=this.a,s=t.childNodes
if(b<0||b>=s.length)return H.k(s,b)
t.replaceChild(c,s[b])},
gE:function(a){var t=this.a.childNodes
return new W.aC(t,t.length)},
aa:function(a,b,c,d){throw H.f(P.A("Cannot setRange on Node list"))},
gk:function(a){return this.a.childNodes.length},
sk:function(a,b){throw H.f(P.A("Cannot set length on immutable List."))},
j:function(a,b){var t=this.a.childNodes
if(b<0||b>=t.length)return H.k(t,b)
return t[b]}}
W.j.prototype={
bW:function(a){var t=a.parentNode
if(t!=null)t.removeChild(a)},
aH:function(a){var t
for(;t=a.firstChild,t!=null;)a.removeChild(t)},
i:function(a){var t=a.nodeValue
return t==null?this.b5(a):t},
$ij:1}
W.aP.prototype={
gk:function(a){return a.length},
j:function(a,b){if(b>>>0!==b||b>=a.length)throw H.f(P.bD(b,a,null,null,null))
return a[b]},
G:function(a,b,c){throw H.f(P.A("Cannot assign element of immutable List."))},
sk:function(a,b){throw H.f(P.A("Cannot resize immutable List."))},
J:function(a,b){if(b<0||b>=a.length)return H.k(a,b)
return a[b]},
$ibG:1,
$iD:1}
W.bW.prototype={
gk:function(a){return a.length}}
W.ao.prototype={$iao:1}
W.P.prototype={}
W.a1.prototype={
gbJ:function(a){var t=a.deltaY
if(t!=null)return t
throw H.f(P.A("deltaY is not supported"))},
$ia1:1}
W.b_.prototype={
bu:function(a,b){return a.requestAnimationFrame(H.bf(b,1))},
bk:function(a){if(!!(a.requestAnimationFrame&&a.cancelAnimationFrame))return;(function(b){var t=['ms','moz','webkit','o']
for(var s=0;s<t.length&&!b.requestAnimationFrame;++s){b.requestAnimationFrame=b[t[s]+'RequestAnimationFrame']
b.cancelAnimationFrame=b[t[s]+'CancelAnimationFrame']||b[t[s]+'CancelRequestAnimationFrame']}if(b.requestAnimationFrame&&b.cancelAnimationFrame)return
b.requestAnimationFrame=function(c){return window.setTimeout(function(){c(Date.now())},16)}
b.cancelAnimationFrame=function(c){clearTimeout(c)}})(a)}}
W.ar.prototype={$iar:1}
W.b0.prototype={
i:function(a){var t,s=a.left
s.toString
s="Rectangle ("+H.i(s)+", "
t=a.top
t.toString
t=s+H.i(t)+") "
s=a.width
s.toString
s=t+H.i(s)+" x "
t=a.height
t.toString
return s+H.i(t)},
O:function(a,b){var t,s
if(b==null)return!1
if(u.q.b(b)){t=a.left
t.toString
s=b.left
s.toString
if(t===s){t=a.top
t.toString
s=b.top
s.toString
if(t===s){t=a.width
t.toString
s=b.width
s.toString
if(t===s){t=a.height
t.toString
s=b.height
s.toString
s=t===s
t=s}else t=!1}else t=!1}else t=!1}else t=!1
return t},
gm:function(a){var t,s,r,q=a.left
q.toString
q=C.a.gm(q)
t=a.top
t.toString
t=C.a.gm(t)
s=a.width
s.toString
s=C.a.gm(s)
r=a.height
r.toString
return W.eB(q,t,s,C.a.gm(r))}}
W.b4.prototype={
gk:function(a){return a.length},
j:function(a,b){if(b>>>0!==b||b>=a.length)throw H.f(P.bD(b,a,null,null,null))
return a[b]},
G:function(a,b,c){throw H.f(P.A("Cannot assign element of immutable List."))},
sk:function(a,b){throw H.f(P.A("Cannot resize immutable List."))},
J:function(a,b){if(b<0||b>=a.length)return H.k(a,b)
return a[b]},
$ibG:1,
$iD:1}
W.dm.prototype={
az:function(a,b){var t,s,r,q,p
for(t=this.gM(),s=t.length,r=this.a,q=0;q<t.length;t.length===s||(0,H.T)(t),++q){p=t[q]
b.$2(p,H.e3(r.getAttribute(p)))}},
gM:function(){var t,s,r,q,p,o,n=this.a.attributes
n.toString
t=H.d([],u.s)
for(s=n.length,r=u.x,q=0;q<s;++q){if(q>=n.length)return H.k(n,q)
p=r.a(n[q])
if(p.namespaceURI==null){o=p.name
o.toString
t.push(o)}}return t}}
W.ch.prototype={
j:function(a,b){return this.a.getAttribute(H.e3(b))},
gk:function(a){return this.gM().length}}
W.dS.prototype={}
W.cn.prototype={}
W.dn.prototype={
$1:function(a){return this.a.$1(a)},
$S:4}
W.as.prototype={
ba:function(a){var t
if($.cr.a===0){for(t=0;t<262;++t)$.cr.G(0,C.A[t],W.hx())
for(t=0;t<12;++t)$.cr.G(0,C.e[t],W.hy())}},
P:function(a){return $.fb().B(0,W.aB(a))},
L:function(a,b,c){var t=$.cr.j(0,W.aB(a)+"::"+b)
if(t==null)t=$.cr.j(0,"*::"+b)
if(t==null)return!1
return t.$4(a,b,c,this)},
$iR:1}
W.aF.prototype={
gE:function(a){return new W.aC(a,this.gk(a))},
l:function(a,b){throw H.f(P.A("Cannot add to immutable List."))},
a3:function(a,b,c){throw H.f(P.A("Cannot modify an immutable List."))},
aa:function(a,b,c,d){throw H.f(P.A("Cannot setRange on immutable List."))}}
W.aQ.prototype={
P:function(a){return C.c.aT(this.a,new W.d7(a))},
L:function(a,b,c){return C.c.aT(this.a,new W.d6(a,b,c))},
$iR:1}
W.d7.prototype={
$1:function(a){return a.P(this.a)},
$S:5}
W.d6.prototype={
$1:function(a){return a.L(this.a,this.b,this.c)},
$S:5}
W.b6.prototype={
bb:function(a,b,c,d){var t,s,r
this.a.a5(0,c)
t=b.a8(0,new W.dw())
s=b.a8(0,new W.dx())
this.b.a5(0,t)
r=this.c
r.a5(0,C.C)
r.a5(0,s)},
P:function(a){return this.a.B(0,W.aB(a))},
L:function(a,b,c){var t=this,s=W.aB(a),r=t.c
if(r.B(0,s+"::"+b))return t.d.bE(c)
else if(r.B(0,"*::"+b))return t.d.bE(c)
else{r=t.b
if(r.B(0,s+"::"+b))return!0
else if(r.B(0,"*::"+b))return!0
else if(r.B(0,s+"::*"))return!0
else if(r.B(0,"*::*"))return!0}return!1},
$iR:1}
W.dw.prototype={
$1:function(a){return!C.c.B(C.e,a)},
$S:6}
W.dx.prototype={
$1:function(a){return C.c.B(C.e,a)},
$S:6}
W.cK.prototype={
L:function(a,b,c){if(this.b8(a,b,c))return!0
if(b==="template"&&c==="")return!0
if(a.getAttribute("template")==="")return this.e.B(0,b)
return!1}}
W.dz.prototype={
$1:function(a){return"TEMPLATE::"+a},
$S:14}
W.cJ.prototype={
P:function(a){var t
if(u.Y.b(a))return!1
t=u.u.b(a)
if(t&&W.aB(a)==="foreignObject")return!1
if(t)return!0
return!1},
L:function(a,b,c){if(b==="is"||C.j.b4(b,"on"))return!1
return this.P(a)},
$iR:1}
W.aC.prototype={
q:function(){var t=this,s=t.c+1,r=t.b
if(s<r){t.d=J.a(t.a,s)
t.c=s
return!0}t.d=null
t.c=r
return!1},
gp:function(){return H.ad(this).c.a(this.d)}}
W.cM.prototype={
a9:function(a){}}
W.dv.prototype={}
W.cP.prototype={
a9:function(a){var t,s=new W.dC(this)
do{t=this.b
s.$2(a,null)}while(t!==this.b)},
V:function(a,b){++this.b
if(b==null||b!==a.parentNode)J.ee(a)
else b.removeChild(a)},
by:function(a,b){var t,s,r,q,p,o=!0,n=null,m=null
try{n=J.fg(a)
m=n.a.getAttribute("is")
t=function(c){if(!(c.attributes instanceof NamedNodeMap))return true
if(c.id=='lastChild'||c.name=='lastChild'||c.id=='previousSibling'||c.name=='previousSibling'||c.id=='children'||c.name=='children')return true
var l=c.childNodes
if(c.lastChild&&c.lastChild!==l[l.length-1])return true
if(c.children)if(!(c.children instanceof HTMLCollection||c.children instanceof NodeList))return true
var k=0
if(c.children)k=c.children.length
for(var j=0;j<k;j++){var i=c.children[j]
if(i.id=='attributes'||i.name=='attributes'||i.id=='lastChild'||i.name=='lastChild'||i.id=='previousSibling'||i.name=='previousSibling'||i.id=='children'||i.name=='children')return true}return false}(a)
o=t?!0:!(a.attributes instanceof NamedNodeMap)}catch(q){H.bj(q)}s="element unprintable"
try{s=J.bl(a)}catch(q){H.bj(q)}try{r=W.aB(a)
this.bx(a,b,o,s,r,n,m)}catch(q){if(H.bj(q) instanceof P.U)throw q
else{this.V(a,b)
window
p="Removing corrupted element "+H.i(s)
if(typeof console!="undefined")window.console.warn(p)}}},
bx:function(a,b,c,d,e,f,g){var t,s,r,q,p,o,n=this
if(c){n.V(a,b)
window
t="Removing element due to corrupted attributes on <"+d+">"
if(typeof console!="undefined")window.console.warn(t)
return}if(!n.a.P(a)){n.V(a,b)
window
t="Removing disallowed element <"+e+"> from "+H.i(b)
if(typeof console!="undefined")window.console.warn(t)
return}if(g!=null)if(!n.a.L(a,"is",g)){n.V(a,b)
window
t="Removing disallowed type extension <"+e+' is="'+g+'">'
if(typeof console!="undefined")window.console.warn(t)
return}t=f.gM()
s=H.d(t.slice(0),H.dE(t))
for(r=f.gM().length-1,t=f.a;r>=0;--r){if(r>=s.length)return H.k(s,r)
q=s[r]
p=n.a
o=J.fj(q)
H.e3(q)
if(!p.L(a,o,t.getAttribute(q))){window
p="Removing disallowed attribute <"+e+" "+q+'="'+H.i(t.getAttribute(q))+'">'
if(typeof console!="undefined")window.console.warn(p)
t.removeAttribute(q)}}if(u.f.b(a)){t=a.content
t.toString
n.a9(t)}}}
W.dC.prototype={
$2:function(a,b){var t,s,r,q,p,o=this.a
switch(a.nodeType){case 1:o.by(a,b)
break
case 8:case 11:case 3:case 4:break
default:o.V(a,b)}t=a.lastChild
for(;null!=t;){s=null
try{s=t.previousSibling
if(s!=null){r=s.nextSibling
q=t
q=r==null?q!=null:r!==q
r=q}else r=!1
if(r){r=P.de("Corrupt HTML")
throw H.f(r)}}catch(p){H.bj(p)
r=t;++o.b
q=r.parentNode
if(a!==q){if(q!=null)q.removeChild(r)}else a.removeChild(r)
t=null
s=a.lastChild}if(t!=null)this.$2(t,a)
t=s}},
$S:15}
W.cf.prototype={}
W.cx.prototype={}
W.cy.prototype={}
W.cQ.prototype={}
W.cR.prototype={}
P.o.prototype={}
P.an.prototype={$ian:1}
P.h.prototype={
at:function(a,b,c,d){var t,s,r,q,p,o
if(c==null){if(d==null){t=H.d([],u.Q)
d=new W.aQ(t)
t.push(W.eA(null))
t.push(W.eF())
t.push(new W.cJ())}c=new W.cP(d)}s='<svg version="1.1">'+b+"</svg>"
t=document
r=t.body
r.toString
q=C.o.bI(r,s,c)
p=t.createDocumentFragment()
t=new W.ca(q)
o=t.gb3(t)
for(;t=o.firstChild,t!=null;)p.appendChild(t)
return p},
$ih:1}
P.ac.prototype={$iac:1}
V.al.prototype={
aw:function(a){var t=this
return t.a===a.a&&t.b===a.b&&t.c===a.c&&t.d===a.d}}
V.d5.prototype={
gaY:function(){var t=this.b
return(this.a.e-this.e-t.d)/t.b},
ga2:function(){var t=this.c
return(this.a.e-this.e-t.d)/t.b}}
D.bM.prototype={
Z:function(a){},
a_:function(a){var t=this.a.r,s=a.b,r=a.d,q=C.a.b_(((r-s.c)/s.a-t.c)/t.a,3),p=C.a.b_((a.gaY()-t.d)/t.b,3)
t=this.b
t.a=r+3
t.b=a.e-3
t.d=q+", "+p
a.r=!0},
a0:function(a){},
$iX:1}
D.bN.prototype={
Z:function(a){},
a_:function(a){var t=a.b.a1(this.a.r),s=a.d,r=t.c,q=t.a,p=(s-r)/q,o=(a.a.e-a.e-t.d)/t.b,n=p-(s+10-r)/q
q=this.b
q.X(0)
q.l(0,H.d([p-n,o,p+n,o,p,o-n,p,o+n],u.n))
a.r=!0},
a0:function(a){},
$iX:1}
D.bO.prototype={
Z:function(a){var t=this,s=a.f.aw(t.d)
if(s){s=t.a
t.r=s.c
t.x=s.d
t.e=a.d
t.f=a.e
t.y=!0}},
aM:function(a){return this.r+(a.d-this.e)/a.b.a},
aN:function(a){return this.x-(a.e-this.f)/a.b.b},
a_:function(a){var t=this
if(t.y){t.b.$2(t.aM(a),t.aN(a))
a.r=!0}},
a0:function(a){var t=this
if(t.y){t.b.$2(t.aM(a),t.aN(a))
t.y=!1
a.r=!0}},
$iX:1}
O.dc.prototype={}
Y.aa.prototype={
b2:function(a,b){var t=this.r
t.c=a
t.d=b
return null},
bU:function(a,b){var t,s,r
for(t=this.x,s=t.length,r=0;r<t.length;t.length===s||(0,H.T)(t),++r)t[r].Z(b)},
aX:function(a,b){var t,s,r
for(t=this.x,s=t.length,r=0;r<t.length;t.length===s||(0,H.T)(t),++r)t[r].a_(b)},
bV:function(a,b){var t,s,r
for(t=this.x,s=t.length,r=0;r<t.length;t.length===s||(0,H.T)(t),++r)t[r].a0(b)}}
Y.bq.prototype={
gI:function(){return 2},
w:function(a){var t=this
return a.bK(J.a(t.gh(t),0),J.a(t.gh(t),1),t.a)},
v:function(a){var t,s,r=this,q=T.y()
for(t=J.m(J.a(r.gh(r),0))-1;t>=0;--t)q.n(0,J.a(J.a(r.gh(r),0),t),J.a(J.a(r.gh(r),1),t))
if(!q.a){s=r.a
q.n(0,q.b-s,q.c-s)
q.n(0,q.d+s,q.e+s)}return a.F(0,q)},
$in:1}
Y.br.prototype={
gI:function(){return 3},
w:function(a){var t=this
return a.bL(J.a(t.gh(t),0),J.a(t.gh(t),1),J.a(t.gh(t),2))},
v:function(a){var t,s,r,q,p=this,o=T.y()
for(t=J.m(J.a(p.gh(p),0))-1;t>=0;--t){s=J.a(J.a(p.gh(p),2),t)
r=J.a(J.a(p.gh(p),0),t)
q=J.a(J.a(p.gh(p),1),t)
o.n(0,r-s,q-s)
o.n(0,r+s,q+s)}return a.F(0,o)},
$in:1}
Y.bw.prototype={
gI:function(){return 2},
w:function(a){var t=this
return a.bN(J.a(t.gh(t),0),J.a(t.gh(t),1),t.a,t.b)},
v:function(a){var t,s,r,q=this,p=T.y()
for(t=J.m(J.a(q.gh(q),0))-1;t>=0;--t)p.n(0,J.a(J.a(q.gh(q),0),t),J.a(J.a(q.gh(q),1),t))
if(!p.a){s=q.a
r=q.b
p.n(0,p.b-s,p.c-r)
p.n(0,p.d+s,p.e+r)}return a.F(0,p)},
$in:1}
Y.bx.prototype={
gI:function(){return 4},
w:function(a){var t=this
return a.bM(J.a(t.gh(t),0),J.a(t.gh(t),1),J.a(t.gh(t),2),J.a(t.gh(t),3))},
v:function(a){var t,s,r,q,p,o=this,n=T.y()
for(t=J.m(J.a(o.gh(o),0))-1;t>=0;--t){s=J.a(J.a(o.gh(o),2),t)
r=J.a(J.a(o.gh(o),3),t)
q=J.a(J.a(o.gh(o),0),t)
p=J.a(J.a(o.gh(o),1),t)
n.n(0,q-s,p-r)
n.n(0,q+s,p+r)}return a.F(0,n)},
$in:1}
Y.bI.prototype={
gI:function(){return 2},
w:function(a){var t=this
return a.bS(J.a(t.gh(t),0),J.a(t.gh(t),1))},
v:function(a){var t,s=this,r=T.y()
for(t=J.m(J.a(s.gh(s),0))-1;t>=0;--t)r.n(0,J.a(J.a(s.gh(s),0),t),J.a(J.a(s.gh(s),1),t))
return a.F(0,r)},
$in:1}
Y.bJ.prototype={
gI:function(){return 4},
w:function(a){var t=this
return a.bO(J.a(t.gh(t),0),J.a(t.gh(t),1),J.a(t.gh(t),2),J.a(t.gh(t),3))},
v:function(a){var t,s=this,r=T.y()
for(t=J.m(J.a(s.gh(s),0))-1;t>=0;--t){r.n(0,J.a(J.a(s.gh(s),0),t),J.a(J.a(s.gh(s),1),t))
r.n(0,J.a(J.a(s.gh(s),2),t),J.a(J.a(s.gh(s),3),t))}return a.F(0,r)},
$in:1}
Y.bS.prototype={
gI:function(){return 2},
w:function(a){var t=this
return a.bP(J.a(t.gh(t),0),J.a(t.gh(t),1))},
v:function(a){var t,s=this,r=T.y()
for(t=J.m(J.a(s.gh(s),0))-1;t>=0;--t)r.n(0,J.a(J.a(s.gh(s),0),t),J.a(J.a(s.gh(s),1),t))
return a.F(0,r)},
$in:1}
Y.bR.prototype={
gI:function(){return 2},
w:function(a){var t=this
return a.au(J.a(t.gh(t),0),J.a(t.gh(t),1))},
v:function(a){var t,s=this,r=T.y()
for(t=J.m(J.a(s.gh(s),0))-1;t>=0;--t)r.n(0,J.a(J.a(s.gh(s),0),t),J.a(J.a(s.gh(s),1),t))
return a.F(0,r)},
$in:1}
Y.bT.prototype={
gI:function(){return 2},
w:function(a){var t=this
return a.bQ(J.a(t.gh(t),0),J.a(t.gh(t),1),t.a,t.b)},
v:function(a){var t,s=this,r=T.y()
for(t=J.m(J.a(s.gh(s),0))-1;t>=0;--t)r.n(0,J.a(J.a(s.gh(s),0),t),J.a(J.a(s.gh(s),1),t))
if(!r.a)r.n(0,r.d+s.a,r.e+s.b)
return a.F(0,r)},
$in:1}
Y.bU.prototype={
gI:function(){return 4},
w:function(a){var t=this
return a.bR(J.a(t.gh(t),0),J.a(t.gh(t),1),J.a(t.gh(t),2),J.a(t.gh(t),3))},
v:function(a){var t,s,r,q,p,o=this,n=T.y()
for(t=J.m(J.a(o.gh(o),0))-1;t>=0;--t){s=J.a(J.a(o.gh(o),0),t)
r=J.a(J.a(o.gh(o),1),t)
n.n(0,s,r)
q=J.a(J.a(o.gh(o),2),t)
if(typeof q!=="number")return H.dI(q)
p=J.a(J.a(o.gh(o),3),t)
if(typeof p!=="number")return H.dI(p)
n.n(0,s+q,r+p)}return a.F(0,n)},
$in:1}
Y.bv.prototype={
w:function(a){var t=a.c
a.av(t.b,t.c,t.d,t.e)},
v:function(a){return T.y()},
$in:1}
Y.bB.prototype={
aF:function(a,b,c,d){var t=d.c,s=c.e-c.c,r=(b-t)*s/(d.e-t)
if(r>0&&r<s)a.push(r)},
ag:function(a,b,c,d,e,f,g){var t,s,r,q,p
if(g>0){t=d/10
s=e+d
r=g-1
this.ag(a,b,c,t,e,s,r)
if(s!==e){if(r>=a.length)return H.k(a,r)
q=a[r]
for(;s<f;s=p){this.aF(q,s,b,c)
p=s+d
this.ag(a,b,c,t,s,p,r)}}}},
aG:function(a,b,c,d){var t=d.b,s=c.d-c.b,r=(b-t)*s/(d.d-t)
if(r>0&&r<s)a.push(r)},
ai:function(a,b,c,d,e,f,g){var t,s,r,q,p
if(g<=0)return
t=d/10
s=g-1
if(s>=a.length)return H.k(a,s)
r=a[s]
q=e+d
this.ai(a,b,c,t,e,q,s)
for(;q<f;q=p){this.aG(r,q,b,c)
p=q+d
this.ai(a,b,c,t,q,p,s)}},
bi:function(a,a0,a1){var t,s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d=this,c=Math.max(C.a.a7(Math.log(a1.d-a1.b)/2.302585092994046),C.a.a7(Math.log(a1.e-a1.c)/2.302585092994046)),b=c-Math.min(C.a.a7(Math.log((a1.d-a1.b)*5/(a0.d-a0.b))/2.302585092994046),C.a.a7(Math.log((a1.e-a1.c)*5/(a0.e-a0.c))/2.302585092994046))
if(b<=0){c=1
b=1}t=Math.pow(10,c-1)
s=Math.ceil(a1.d/t)
r=Math.floor(a1.b/t)
q=Math.ceil(a1.e/t)
p=Math.floor(a1.c/t)
o=u.b
n=H.d([],o)
m=H.d([],o)
for(o=u.n,l=0;l<b;++l){n.push(H.d([],o))
m.push(H.d([],o))}d.ag(n,a0,a1,t,p*t,q*t,b)
d.ai(m,a0,a1,t,r*t,s*t,b)
for(s=d.a,r=s.a,q=d.b,p=q.a-r,o=s.b,k=q.b-o,s=s.c,q=q.c-s,l=0;l<b;++l){j=l/b
a.sR(0,new T.p(T.b(r+j*p),T.b(o+j*k),T.b(s+j*q),T.b(1)))
if(l>=n.length)return H.k(n,l)
i=n[l]
h=i.length
g=0
for(;g<i.length;i.length===h||(0,H.T)(i),++g){f=i[g]
a.Y(a0.b,f,a0.d,f)}if(l>=m.length)return H.k(m,l)
i=m[l]
h=i.length
g=0
for(;g<i.length;i.length===h||(0,H.T)(i),++g){e=i[g]
a.Y(e,a0.c,e,a0.e)}}},
w:function(a){var t,s,r,q,p,o=this,n=a.b,m=a.d
m.toString
n.toString
t=m.c0(n)
if(t.d-t.b<=0)return
if(t.e-t.c<=0)return
s=a.d
a.d=T.ew()
o.bi(a,n,t)
if(t.b<=0&&t.d>=0){r=H.d([],u.n)
o.aG(r,0,n,t)
if(r.length===1){a.sR(0,o.c)
if(0>=r.length)return H.k(r,0)
q=r[0]
a.Y(q,n.c,q,n.e)}}if(t.c<=0&&t.e>=0){r=H.d([],u.n)
o.aF(r,0,n,t)
if(r.length===1){a.sR(0,o.c)
if(0>=r.length)return H.k(r,0)
p=r[0]
a.Y(n.b,p,n.d,p)}}a.d=s},
v:function(a){return T.y()},
$in:1}
Y.c0.prototype={
w:function(a){var t,s,r,q,p,o,n=this,m=n.d
if(m.length!==0){t=n.a
s=n.b
r=n.c
if(n.e){q=a.d
p=q.a
q=q.c
o=t*p+q
s=a.C(s)
r=Math.abs((t+r)*p+q-o)
t=o}q=a.a
q.a+='<text x="'+H.i(t)+'" y="'+H.i(s)+'" style="font-family: '+H.i(a.ch)+"; font-size: "+H.i(r)+'px;" '
q.a+=H.i(a.x)+H.i(a.Q)+">"+m+"</text>\n"}},
v:function(a){var t=T.y()
if(this.d.length!==0)t.n(0,this.a,this.b)
return a.F(0,t)},
$in:1}
Y.aE.prototype={
A:function(a){var t,s,r
for(t=a.length,s=this.c,r=0;r<a.length;a.length===t||(0,H.T)(a),++r)s.push(a[r])},
H:function(a,b,c,d,e){var t=new Y.c0(a,b,c,d,e,H.d([],u.E),!0)
this.A(H.d([t],u.m))
return t},
bD:function(a,b,c,d){return this.H(a,b,c,d,!1)},
as:function(a){var t=new Y.bR(null,H.d([],u.E),!0)
t.l(0,a)
this.A(H.d([t],u.m))
return t},
W:function(a){var t=new Y.bJ(null,H.d([],u.E),!0)
t.l(0,a)
this.A(H.d([t],u.m))
return t},
a6:function(a){var t=new Y.bU(null,H.d([],u.E),!0)
t.l(0,a)
this.A(H.d([t],u.m))
return t},
aP:function(a){var t=new Y.br(null,H.d([],u.E),!0)
t.l(0,a)
this.A(H.d([t],u.m))
return t},
aR:function(a){var t=new Y.bx(null,H.d([],u.E),!0)
t.l(0,a)
this.A(H.d([t],u.m))
return t},
aS:function(a,b,c){var t=new Y.bT(a,b,null,H.d([],u.E),!0)
t.l(0,c)
this.A(H.d([t],u.m))
return t},
aO:function(a,b){var t=new Y.bq(a,null,H.d([],u.E),!0)
t.l(0,b)
this.A(H.d([t],u.m))
return t},
aQ:function(a,b,c){var t=new Y.bw(a,b,null,H.d([],u.E),!0)
t.l(0,c)
this.A(H.d([t],u.m))
return t},
w:function(a){var t,s,r
for(t=this.c,s=t.length,r=0;r<t.length;t.length===s||(0,H.T)(t),++r)t[r].aU(a)},
v:function(a){var t,s,r,q,p,o,n=T.y()
for(t=this.c,s=t.length,r=0;r<t.length;t.length===s||(0,H.T)(t),++r){q=t[r].b0(a)
if(n.a){n.a=q.a
n.b=q.b
n.c=q.c
n.d=q.d
n.e=q.e}else if(!q.a){p=n.b
o=q.b
if(p>o)n.b=o
p=n.c
o=q.c
if(p>o)n.c=o
p=n.d
o=q.d
if(p<o)n.d=o
p=n.e
q=q.e
if(p<q)n.e=q}}return n},
$in:1,
gt:function(){return this.b}}
Y.cb.prototype={
gt:function(){return this.b$}}
Y.cc.prototype={}
Y.cd.prototype={
gt:function(){return this.b$}}
Y.ce.prototype={}
Y.cg.prototype={
gt:function(){return this.b$}}
Y.ci.prototype={
gt:function(){return this.b$}}
Y.cj.prototype={}
Y.ck.prototype={
gt:function(){return this.b$}}
Y.cl.prototype={}
Y.cp.prototype={
gt:function(){return this.b$}}
Y.cq.prototype={
gt:function(){return this.b$}}
Y.cs.prototype={
gt:function(){return this.b$}}
Y.ct.prototype={}
Y.cu.prototype={
gt:function(){return this.b$}}
Y.cv.prototype={}
Y.cA.prototype={
gt:function(){return this.b$}}
Y.cB.prototype={}
Y.cC.prototype={
gt:function(){return this.b$}}
Y.cD.prototype={}
Y.cE.prototype={
gt:function(){return this.b$}}
Y.cF.prototype={}
Y.cG.prototype={
gt:function(){return this.b$}}
Y.cH.prototype={}
Y.cL.prototype={
gt:function(){return this.b$}}
N.ay.prototype={
T:function(a){this.b=a.cx
a.cx=!0},
S:function(a){a.cx=this.b
this.b=!1},
$iN:1}
N.bs.prototype={
T:function(a){this.b=a.r
a.sR(0,this.a)},
S:function(a){var t=this.b
t.toString
a.sR(0,t)
this.b=null},
$iN:1}
N.x.prototype={
T:function(a){this.b=a.z
a.sax(this.a)},
S:function(a){a.sax(this.b)
this.b=null},
$iN:1}
N.bz.prototype={
T:function(a){this.b=a.ch
a.ch=this.a},
S:function(a){a.ch=this.b
this.b=null},
$iN:1}
N.ab.prototype={
T:function(a){this.b=a.e
a.e=this.a},
S:function(a){return a.e=this.b},
$iN:1}
N.c1.prototype={
bF:function(a){var t,s
this.c=null
t=this.a
this.c=a
s=a.a1(t)
return s},
T:function(a){var t
this.c=null
t=a.d
this.c=t
a.d=t.a1(this.a)},
S:function(a){var t=this.c
if(t!=null){a.d=t
this.c=null}},
$iN:1,
$iev:1}
N.B.prototype={
u:function(a,b,c){var t=new N.bs(new T.p(T.b(a),T.b(b),T.b(c),T.b(1)))
this.a$.push(t)
return t},
aU:function(a){var t,s,r
this.gt()
t=this.a$
s=t.length
for(r=0;r<s;++r){if(r>=t.length)return H.k(t,r)
t[r].T(a)}this.w(a)
for(r=s-1;r>=0;--r){if(r>=t.length)return H.k(t,r)
t[r].S(a)}},
b0:function(a){var t,s,r,q,p,o,n
this.gt()
t=this.a$
s=t.length
for(r=u.B,q=0;q<s;++q){if(q>=t.length)return H.k(t,q)
p=t[q]
if(r.b(p))a=p.bF(a)}o=this.v(a)
for(q=s-1;q>=0;--q){if(q>=t.length)return H.k(t,q)
p=t[q]
if(r.b(p)){n=p.c
if(n!=null){p.c=null
a=n}}}return o},
gt:function(){return this.b$}}
N.J.prototype={
gh:function(a){var t=this.c$
return t==null?this.c$=new N.cV(this).$0():t},
X:function(a){var t,s=this
for(t=0;t<J.m(s.gh(s));++t)J.ff(J.a(s.gh(s),t))},
l:function(a,b){var t,s,r,q,p=this,o=b.length
for(t=0;t<o;t+=J.m(p.gh(p)))for(s=0;s<J.m(p.gh(p));++s){r=J.a(p.gh(p),s)
q=t+s
if(q<0||q>=b.length)return H.k(b,q)
J.fe(r,b[q])}},
aB:function(a,b){var t,s,r,q,p=this,o=b.length,n=H.d([],u.b)
for(t=u.n,s=0;s<J.m(p.gh(p));++s)n.push(H.d([],t))
for(s=0;s<o;s+=J.m(p.gh(p)))for(r=0;r<J.m(p.gh(p));++r){if(r>=n.length)return H.k(n,r)
t=n[r]
q=s+r
if(q<0||q>=b.length)return H.k(b,q)
t.push(b[q])}for(s=0;s<J.m(p.gh(p));++s)J.fh(J.a(p.gh(p),s),a,J.a(p.gh(p),s))},
aA:function(a,b){var t,s,r,q=this,p=H.d([],u.n)
for(t=0;t<b;++t)for(s=a+t,r=0;r<J.m(q.gh(q));++r)p.push(J.a(J.a(q.gh(q),r),s))
return p}}
N.cV.prototype={
$0:function(){var t,s,r,q=H.d([],u.b)
for(t=this.a,s=u.n,r=0;r<t.gI();++r)q.push(H.d([],s))
return q},
$S:17}
T.a_.prototype={
n:function(a,b,c){var t=this
if(t.a){t.a=!1
t.b=t.d=b
t.c=t.e=c}else{if(t.b>b)t.b=b
if(t.c>c)t.c=c
if(t.d<b)t.d=b
if(t.e<c)t.e=c}},
i:function(a){var t=this
return t.a?"[empty]":"["+H.i(t.b)+", "+H.i(t.c)+", "+H.i(t.d)+", "+H.i(t.e)+"]"},
$idQ:1}
T.ap.prototype={
a1:function(a){var t=this,s=t.a,r=a.a,q=t.b
return new T.ap(s*r,q*a.b,a.c*s+t.c,a.d*q+t.d)},
F:function(a,b){var t,s,r,q,p,o,n=this
if(b.a)return T.y()
else{t=b.b
s=n.a
r=n.c
q=b.c
p=n.b
o=n.d
return new T.a_(!1,t*s+r,q*p+o,b.d*s+r,b.e*p+o)}},
c0:function(a){var t,s,r,q,p,o,n=this
if(a.a)return T.y()
else{t=a.b
s=n.c
r=n.a
q=a.c
p=n.d
o=n.b
return new T.a_(!1,(t-s)/r,(q-p)/o,(a.d-s)/r,(a.e-p)/o)}}}
T.p.prototype={}
Q.am.prototype={
gan:function(){var t=this.d
return t==null?H.ag(new H.aK("Field '_renderer' has not been initialized.")):t},
b9:function(a,b){var t=this,s=t.b,r=Q.hJ(s),q=new K.df(new P.aX(""),T.y(),new T.p(T.b(1),T.b(1),T.b(1),T.b(1)),new Q.d9(r),new Q.da(r))
q.sR(0,new T.p(T.b(0),T.b(0),T.b(0),T.b(1)))
q.sax(null)
t.d=q
q=s.style
q.margin="0px"
q.padding="0px"
q.width="100%"
q.height="100%"
q=t.gbv()
W.b1(s,"resize",q,!1)
W.b1(s,"mousedown",t.gbm(),!1)
W.b1(s,"mousemove",t.gbo(),!1)
W.b1(s,"mouseup",t.gbq(),!1)
W.b1(s,"mousewheel",t.gbs(),!1)
W.b1(window,"resize",q,!1)
t.a.appendChild(s)
t.U()},
U:function(){var t,s
if(!this.e){this.e=!0
t=window
C.n.bk(t)
s=W.eQ(new Q.db(this),u.H)
s.toString
C.n.bu(t,s)}},
gap:function(a){var t,s=this.b.getBoundingClientRect(),r=s.right
r.toString
t=s.left
t.toString
return r-t},
gaj:function(a){var t,s=this.b.getBoundingClientRect(),r=s.bottom
r.toString
t=s.top
t.toString
return r-t},
gam:function(){var t=this,s=t.gap(t),r=t.gaj(t),q=Math.min(s,r)
if(q<=0)q=1
return new T.ap(q,q,0.5*s,0.5*r)},
bw:function(a){return this.U()},
a4:function(a){var t,s,r,q,p,o=this,n=o.b,m=n.createSVGPoint(),l=a.clientX
a.clientY
m.x=l
a.clientX
m.y=a.clientY
t=m.matrixTransform(n.getScreenCTM().inverse())
s=o.gam().a1(o.c.r)
n=o.gap(o)
l=o.gaj(o)
r=o.gam()
q=t.x
q.toString
p=t.y
p.toString
return new V.d5(new T.a_(!1,0,0,n,l),r,s,q,p,new V.al(a.button,a.shiftKey,a.ctrlKey,a.altKey))},
bn:function(a){var t
a.stopPropagation()
a.preventDefault()
t=this.a4(a)
this.c.bU(0,t)
if(t.r)this.U()},
bp:function(a){var t
a.stopPropagation()
a.preventDefault()
t=this.a4(a)
this.c.aX(0,t)
if(t.r)this.U()},
br:function(a){var t
a.stopPropagation()
a.preventDefault()
t=this.a4(a)
this.c.bV(0,t)
if(t.r)this.U()},
bt:function(a){var t,s,r,q,p,o,n,m,l,k
a.stopPropagation()
a.preventDefault()
t=this.a4(a)
s=C.G.gbJ(a)
r=this.c
q=r.r
p=Math.max(q.a,q.b)
o=Math.pow(10,Math.log(p)/2.302585092994046-s/-300)
if(o<0.0001)o=0.0001
else if(o>1e4)o=1e4
s=t.b
n=(t.d-s.c)/s.a
m=t.gaY()
s=q.c
l=o/p
k=q.d
q.c=(s-n)*l+n
q.d=(k-m)*l+m
q.b=q.a=o
t.r=!0
r.aX(0,t)
if(t.r)this.U()}}
Q.d9.prototype={
$1:function(a){var t=this.a,s=t.c,r=t.b
s.textContent=null
if(r instanceof W.cM)s.innerHTML=a
else s.appendChild(C.m.at(s,a,r,t.a))
return null},
$S:19}
Q.da.prototype={
$2:function(a,b){var t=this.a,s=t.c
C.m.aH(s)
s.setAttribute("viewBox","0 0 "+C.a.i(a.d-a.b)+" "+C.a.i(a.e-a.c))
s=s.style
s.backgroundColor=b
return t},
$S:20}
Q.db.prototype={
$1:function(a){var t,s,r,q=this.a
if(q.e){q.e=!1
t=q.gan()
s=new T.a_(!1,0,0,q.gap(q),q.gaj(q))
r=q.gam()
t.b=s
t.d=r
t.db.$2(s,t.af(t.f))
t.a.a=""
t=q.c
s=q.gan()
s.c=t.f
s.d=s.d.a1(t.r)
t.aU(s)
q=q.gan()
s=q.a.a
q.cy.$1(s.charCodeAt(0)==0?s:s)}},
$S:21}
Q.dy.prototype={}
K.df.prototype={
sR:function(a,b){var t,s,r=this
r.r=b
t=r.af(b)
s=b.d
r.x='stroke="'+t+'" stroke-opacity="'+H.i(s)+'" '
r.y='fill="'+t+'" fill-opacity="'+H.i(s)+'" '},
sax:function(a){var t=this
t.z=a
if(a!=null)t.Q='fill="'+t.af(a)+'" fill-opacity="'+H.i(a.d)+'" '
else t.Q='fill="none" '},
aV:function(a,b){var t,s=this,r=s.d,q=r.a
r=r.c
b=s.C(b)
t=s.e
if(t<=1)t=1
r='<circle cx="'+C.a.i(a*q+r)+'" cy="'+C.a.i(b)+'" r="'+C.b.i(t)+'" '
q=s.y
q.toString
s.a.a+=r+q+" />\n"},
au:function(a,b){var t,s,r,q,p,o,n,m,l,k,j,i=this
for(t=J.l(a),s=t.gk(a)-1,r=J.l(b);s>=0;--s){q=t.j(a,s)
p=r.j(b,s)
o=i.d
n=o.a
m=o.c
l=i.b.e
k=o.b
o=o.d
j=i.e
if(j<=1)j=1
i.bC(q*n+m,l-(p*k+o),j)}},
Y:function(a,b,c,d){var t,s,r=this,q=r.d,p=q.a
q=q.c
t=r.C(b)
s=r.d
r.ac(a,b,c,d,a*p+q,t,c*s.a+s.c,r.C(d))
if(r.e>1){r.aV(a,b)
r.aV(c,d)}},
ac:function(a,b,c,d,e,f,g,h){var t,s,r,q,p,o,n,m=this
m.ar(e,f,g,h)
if(m.cx){t=c-a
s=d-b
r=Math.sqrt(t*t+s*s)
if(r>1e-12){t/=r
s/=r
q=g-t*6
p=s*4
o=h+s*6
n=t*4
m.ar(g,h,q+p,o+n)
m.ar(g,h,q-p,o-n)}}},
bO:function(a,b,c,d){var t,s,r,q,p
for(t=J.l(a),s=t.gk(a)-1,r=J.l(b),q=J.l(c),p=J.l(d);s>=0;--s)this.Y(t.j(a,s),r.j(b,s),q.j(c,s),p.j(d,s))},
av:function(a,b,c,d){var t,s=this,r=s.d
a=a*r.a+r.c
b=s.C(b)
r=s.d
t=r.a
r=r.c
d=s.C(d)
r='<rect x="'+C.a.i(a)+'" y="'+C.a.i(d)+'" width="'+C.a.i(c*t+r-a)+'" height="'+C.a.i(b-d)+'" '
t=s.Q
t.toString
t=r+t
r=s.x
r.toString
s.a.a+=t+r+"/>\n"},
bR:function(a,b,c,d){var t,s,r,q,p,o,n,m,l
for(t=J.l(a),s=t.gk(a)-1,r=J.l(b),q=J.l(c),p=J.l(d);s>=0;--s){o=t.j(a,s)
n=r.j(b,s)
m=q.j(c,s)
if(typeof m!=="number")return H.dI(m)
l=p.j(d,s)
if(typeof l!=="number")return H.dI(l)
this.av(o,n,o+m,n+l)}},
bQ:function(a,b,c,d){var t,s,r,q,p
for(t=J.l(a),s=t.gk(a)-1,r=J.l(b);s>=0;--s){q=t.j(a,s)
p=r.j(b,s)
this.av(q,p,q+c,p+d)}},
aJ:function(a,b,c,d){var t,s,r,q=this,p=q.d
a=a*p.a+p.c
b=q.C(b)
p=q.d
c=c*p.a+p.c
d=q.C(d)
if(a>c){t=c
c=a
a=t}if(b>d){t=d
d=b
b=t}s=Math.abs(c-a)*0.5
r=Math.abs(d-b)*0.5
q.aq(a+s,b+r,s,r)},
bM:function(a,b,c,d){var t,s,r,q,p,o,n,m,l
for(t=J.l(a),s=t.gk(a)-1,r=J.l(c),q=J.l(d),p=J.l(b);s>=0;--s){o=r.j(c,s)
n=q.j(d,s)
m=t.j(a,s)
l=p.j(b,s)
this.aJ(m-o,l-n,m+o,l+n)}},
bN:function(a,b,c,d){var t,s,r,q,p
for(t=J.l(a),s=t.gk(a)-1,r=J.l(b);s>=0;--s){q=t.j(a,s)
p=r.j(b,s)
this.aJ(q-c,p-d,q+c,p+d)}},
bL:function(a,b,c){var t,s,r,q,p,o,n,m,l,k,j,i,h,g
for(t=J.l(a),s=t.gk(a)-1,r=J.l(c),q=J.l(b);s>=0;--s){p=r.j(c,s)
o=t.j(a,s)
n=q.j(b,s)
m=this.d
l=m.a
k=m.c
j=this.b.e
i=m.b
m=m.d
h=o*l+k
g=j-(n*i+m)
this.aq(h,g,Math.abs((o+p)*l+k-h),Math.abs(j-((n+p)*i+m)-g))}},
bK:function(a,b,c){var t,s,r,q,p,o,n,m,l,k,j,i
for(t=J.l(a),s=t.gk(a)-1,r=J.l(b);s>=0;--s){q=t.j(a,s)
p=r.j(b,s)
o=this.d
n=o.a
m=o.c
l=this.b.e
k=o.b
o=o.d
j=q*n+m
i=l-(p*k+o)
this.aq(j,i,Math.abs((q+c)*n+m-j),Math.abs(l-((p+c)*k+o)-i))}},
bP:function(a2,a3){var t,s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a=this,a0=J.l(a2),a1=a0.gk(a2)
if(a1>=3){t=a0.j(a2,0)
s=a.d
r=s.a
s=s.c
q=J.l(a3)
p=a.C(q.j(a3,0))
o=a.a
o.a+='<polygon points="'+H.i(t*r+s)+","+H.i(p)
for(n=1;n<a1;++n){t=a0.j(a2,n)
s=a.d
r=s.a
s=s.c
m=q.j(a3,n)
l=a.b.e
k=a.d
j=k.b
k=k.d
o.a+=" "+H.i(t*r+s)+","+H.i(l-(m*j+k))}o.a+='" '+H.i(a.Q)+H.i(a.x)+"/>\n"
if(a.cx){t=a1-1
i=a0.j(a2,t)
h=q.j(a3,t)
t=a.d
g=i*t.a+t.c
f=a.C(h)
for(n=0;n<a1;++n,f=b,g=c,h=d,i=e){e=a0.j(a2,n)
d=q.j(a3,n)
t=a.d
c=e*t.a+t.c
b=a.b.e-(d*t.b+t.d)
a.ac(i,h,e,d,g,f,c,b)}}}if(a.e>1)a.au(a2,a3)},
bS:function(a2,a3){var t,s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a=this,a0=J.l(a2),a1=a0.gk(a2)
if(a1>=2){t=a0.j(a2,0)
s=a.d
r=s.a
s=s.c
q=J.l(a3)
p=a.C(q.j(a3,0))
o=a.a
s=o.a+='<polyline points="'+C.a.i(t*r+s)+","+C.a.i(p)
for(t=s,n=1;n<a1;++n,t=k){t=a0.j(a2,n)
s=a.d
r=s.a
s=s.c
m=q.j(a3,n)
l=a.b.e
k=a.d
j=k.b
k=k.d
k=o.a+=" "+H.i(t*r+s)+","+H.i(l-(m*j+k))}s=a.x
s.toString
o.a=t+('" fill="none" '+s+"/>\n")
if(a.cx){i=a0.j(a2,0)
h=q.j(a3,0)
t=a.d
g=i*t.a+t.c
f=a.C(h)
for(n=1;n<a1;++n,f=b,g=c,h=d,i=e){e=a0.j(a2,n)
d=q.j(a3,n)
t=a.d
c=e*t.a+t.c
b=a.b.e-(d*t.b+t.d)
a.ac(i,h,e,d,g,f,c,b)}}}if(a.e>1)a.au(a2,a3)},
C:function(a){var t=this.b.e,s=this.d
return t-(a*s.b+s.d)},
af:function(a){var t=C.a.ay(a.a*255),s=C.a.ay(a.b*255),r=C.a.ay(a.c*255)
return"rgb("+C.b.i(t)+", "+C.b.i(s)+", "+C.b.i(r)+")"},
bC:function(a,b,c){var t='<circle cx="'+C.a.i(a)+'" cy="'+C.a.i(b)+'" r="'+C.b.i(c)+'" ',s=this.y
s.toString
this.a.a+=t+s+" />\n"
return null},
ar:function(a,b,c,d){var t='<line x1="'+C.a.i(a)+'" y1="'+C.a.i(b)+'" x2="'+C.a.i(c)+'" y2="'+C.a.i(d)+'" ',s=this.x
s.toString
this.a.a+=t+s+"/>\n"
return null},
aq:function(a,b,c,d){var t='<ellipse cx="'+C.a.i(a)+'" cy="'+C.a.i(b)+'" rx="'+C.a.i(c)+'" ry="'+C.a.i(d)+'" ',s=this.Q
s.toString
s=t+s
t=this.x
t.toString
this.a.a+=s+t+"/>\n"
return null}}
F.dN.prototype={
$1:function(a){var t=document.querySelector("#output")
t.toString
return Q.fy(t,a)},
$S:22}
F.c8.prototype={
Z:function(a){var t,s
if(a.f.aw(C.E)){this.a=!0
t=a.c
s=a.d
this.b.l(0,H.d([(s-t.c)/t.a,a.ga2(),(s-t.c)/t.a,a.ga2()],u.n))
a.r=!0}},
a_:function(a){var t,s,r,q
if(this.a){t=this.b
s=t.aA(J.m(J.a(t.gh(t),0))-1,1)
r=a.c
q=r.c
r=r.a
if(2>=s.length)return H.k(s,2)
s[2]=(a.d-q)/r
r=a.ga2()
if(3>=s.length)return H.k(s,3)
s[3]=r
t.aB(J.m(J.a(t.gh(t),0))-1,s)
a.r=!0}},
a0:function(a){var t,s,r,q
if(this.a){t=this.b
s=t.aA(J.m(J.a(t.gh(t),0))-1,1)
r=a.c
q=r.c
r=r.a
if(2>=s.length)return H.k(s,2)
s[2]=(a.d-q)/r
r=a.ga2()
if(3>=s.length)return H.k(s,3)
s[3]=r
t.aB(J.m(J.a(t.gh(t),0))-1,s)
a.r=!0
this.a=!1}},
$iX:1}
F.cz.prototype={
Z:function(a){var t
if(a.f.aw(C.F)){this.b=!0
t=a.c
this.a.l(0,H.d([(a.d-t.c)/t.a,a.ga2()],u.n))
a.r=!0}},
a_:function(a){},
a0:function(a){if(this.b)this.b=!1},
$iX:1};(function aliases(){var t=J.z.prototype
t.b5=t.i
t=J.a8.prototype
t.b7=t.i
t=P.C.prototype
t.b6=t.a8
t=W.b6.prototype
t.b8=t.L})();(function installTearOffs(){var t=hunkHelpers._static_1,s=hunkHelpers._static_0,r=hunkHelpers.installStaticTearOff,q=hunkHelpers._instance_2u,p=hunkHelpers._instance_1u
t(P,"hq","fE",2)
t(P,"hr","fF",2)
t(P,"hs","fG",2)
s(P,"eS","hk",0)
r(W,"hx",4,null,["$4"],["fH"],7,0)
r(W,"hy",4,null,["$4"],["fI"],7,0)
q(Y.aa.prototype,"gb1","b2",16)
var o
p(o=Q.am.prototype,"gbv","bw",4)
p(o,"gbm","bn",1)
p(o,"gbo","bp",1)
p(o,"gbq","br",1)
p(o,"gbs","bt",18)})();(function inheritance(){var t=hunkHelpers.mixin,s=hunkHelpers.inherit,r=hunkHelpers.inheritMany
s(P.u,null)
r(P.u,[H.dU,J.z,J.bo,P.q,P.C,H.aN,P.bE,H.dg,H.d8,H.cI,H.a6,P.a9,H.d1,H.bK,H.O,H.co,P.dA,P.c9,P.bZ,P.dD,P.ba,P.ds,P.cw,P.b3,P.F,P.aV,P.aW,P.dp,P.M,P.aX,W.cX,W.dS,W.as,W.aF,W.aQ,W.b6,W.cJ,W.aC,W.cM,W.dv,W.cP,V.al,V.d5,D.bM,D.bN,D.bO,O.dc,Y.cq,Y.cb,Y.cd,Y.ci,Y.ck,Y.cs,Y.cu,Y.cC,Y.cA,Y.cE,Y.cG,Y.cg,Y.cp,Y.cL,N.ay,N.bs,N.x,N.bz,N.ab,N.c1,N.B,N.J,T.a_,T.ap,T.p,Q.am,Q.dy,F.c8,F.cz])
r(J.z,[J.d_,J.aH,J.a8,J.w,J.aI,J.a7,W.by,W.cf,W.cY,W.az,W.c,W.d3,W.cx,W.cQ])
r(J.a8,[J.bQ,J.aq,J.W])
s(J.d0,J.w)
r(J.aI,[J.aG,J.bF])
r(P.q,[H.aK,P.c2,H.bH,H.c4,H.bV,H.cm,P.bp,P.bP,P.U,P.c5,P.c3,P.bX,P.bt,P.bu])
r(P.C,[H.aA,H.aZ])
r(H.aA,[H.ak,H.aL])
r(H.ak,[H.aY,H.aO])
s(H.c6,P.bE)
s(H.aR,P.c2)
r(H.a6,[H.c_,H.dJ,H.dK,H.dL,P.dj,P.di,P.dk,P.dl,P.dB,P.dF,P.du,P.d4,W.dn,W.d7,W.d6,W.dw,W.dx,W.dz,W.dC,N.cV,Q.d9,Q.da,Q.db,F.dN])
r(H.c_,[H.bY,H.ai])
s(P.bL,P.a9)
r(P.bL,[H.aJ,W.dm])
s(H.b7,H.cm)
s(P.dt,P.dD)
s(P.b5,P.ba)
s(P.b2,P.b5)
s(P.aM,P.b3)
r(P.U,[P.aT,P.bC])
r(W.by,[W.j,W.b_])
r(W.j,[W.v,W.Q,W.ar])
r(W.v,[W.e,P.h])
r(W.e,[W.bm,W.bn,W.ah,W.a5,W.bA,W.bW,W.ao])
s(W.ax,W.cf)
s(W.P,W.c)
s(W.K,W.P)
s(W.ca,P.aM)
s(W.cy,W.cx)
s(W.aP,W.cy)
s(W.a1,W.K)
s(W.b0,W.az)
s(W.cR,W.cQ)
s(W.b4,W.cR)
s(W.ch,W.dm)
s(W.cn,P.bZ)
s(W.cK,W.b6)
r(P.h,[P.o,P.an])
s(P.ac,P.o)
s(Y.aE,Y.cq)
s(Y.aa,Y.aE)
s(Y.cc,Y.cb)
s(Y.bq,Y.cc)
s(Y.ce,Y.cd)
s(Y.br,Y.ce)
s(Y.cj,Y.ci)
s(Y.bw,Y.cj)
s(Y.cl,Y.ck)
s(Y.bx,Y.cl)
s(Y.ct,Y.cs)
s(Y.bI,Y.ct)
s(Y.cv,Y.cu)
s(Y.bJ,Y.cv)
s(Y.cD,Y.cC)
s(Y.bS,Y.cD)
s(Y.cB,Y.cA)
s(Y.bR,Y.cB)
s(Y.cF,Y.cE)
s(Y.bT,Y.cF)
s(Y.cH,Y.cG)
s(Y.bU,Y.cH)
s(Y.bv,Y.cg)
s(Y.bB,Y.cp)
s(Y.c0,Y.cL)
s(K.df,O.dc)
t(P.b3,P.F)
t(P.ba,P.aV)
t(W.cf,W.cX)
t(W.cx,P.F)
t(W.cy,W.aF)
t(W.cQ,P.F)
t(W.cR,W.aF)
t(Y.cb,N.B)
t(Y.cc,N.J)
t(Y.cd,N.B)
t(Y.ce,N.J)
t(Y.cg,N.B)
t(Y.ci,N.B)
t(Y.cj,N.J)
t(Y.ck,N.B)
t(Y.cl,N.J)
t(Y.cp,N.B)
t(Y.cq,N.B)
t(Y.cs,N.B)
t(Y.ct,N.J)
t(Y.cu,N.B)
t(Y.cv,N.J)
t(Y.cA,N.B)
t(Y.cB,N.J)
t(Y.cC,N.B)
t(Y.cD,N.J)
t(Y.cE,N.B)
t(Y.cF,N.J)
t(Y.cG,N.B)
t(Y.cH,N.J)
t(Y.cL,N.B)})()
var v={typeUniverse:{eC:new Map(),tR:{},eT:{},tPV:{},sEA:[]},mangledGlobalNames:{hC:"int",I:"double",S:"num",r:"String",av:"bool",M:"Null",D:"List"},mangledNames:{},getTypeFromName:getGlobalFromName,metadata:[],types:["~()","~(K)","~(~())","M()","~(c)","av(R)","av(r)","av(v,r,r,as)","@(@)","@(@,r)","@(r)","M(@)","M(~())","~(u?,u?)","r(r)","~(j,j?)","~(I,I)","D<D<I>>()","~(a1)","~(r)","~(dQ,r)","~(S)","am(aa)"],interceptorsByTag:null,leafTags:null,arrayRti:typeof Symbol=="function"&&typeof Symbol()=="symbol"?Symbol("$ti"):"$ti"}
H.fW(v.typeUniverse,JSON.parse('{"bQ":"a8","aq":"a8","W":"a8","hP":"c","hX":"c","hQ":"h","hR":"h","hO":"o","hS":"e","hZ":"e","hY":"j","hW":"j","hU":"P","hT":"Q","i0":"Q","i_":"K","w":{"D":["1"]},"d0":{"w":["1"],"D":["1"]},"aI":{"I":[],"S":[]},"aG":{"I":[],"S":[]},"bF":{"I":[],"S":[]},"a7":{"r":[]},"aK":{"q":[]},"aA":{"C":["1"]},"ak":{"C":["1"]},"aY":{"ak":["1"],"C":["1"],"C.E":"1"},"aO":{"ak":["2"],"C":["2"],"C.E":"2"},"aZ":{"C":["1"],"C.E":"1"},"aR":{"q":[]},"bH":{"q":[]},"c4":{"q":[]},"a6":{"aD":[]},"c_":{"aD":[]},"bY":{"aD":[]},"ai":{"aD":[]},"bV":{"q":[]},"aJ":{"a9.V":"2"},"aL":{"C":["1"],"C.E":"1"},"cm":{"q":[]},"b7":{"q":[]},"b2":{"aV":["1"]},"aM":{"F":["1"],"D":["1"]},"b5":{"aV":["1"]},"I":{"S":[]},"bp":{"q":[]},"c2":{"q":[]},"bP":{"q":[]},"U":{"q":[]},"aT":{"q":[]},"bC":{"q":[]},"c5":{"q":[]},"c3":{"q":[]},"bX":{"q":[]},"bt":{"q":[]},"aW":{"q":[]},"bu":{"q":[]},"v":{"j":[]},"K":{"c":[]},"P":{"c":[]},"a1":{"K":[],"c":[]},"as":{"R":[]},"e":{"v":[],"j":[]},"bm":{"v":[],"j":[]},"bn":{"v":[],"j":[]},"ah":{"v":[],"j":[]},"a5":{"v":[],"j":[]},"Q":{"j":[]},"az":{"dX":["S"]},"bA":{"v":[],"j":[]},"ca":{"F":["j"],"D":["j"],"F.E":"j"},"aP":{"F":["j"],"D":["j"],"bG":["j"],"F.E":"j"},"bW":{"v":[],"j":[]},"ao":{"v":[],"j":[]},"ar":{"j":[]},"b0":{"dX":["S"]},"b4":{"F":["j"],"D":["j"],"bG":["j"],"F.E":"j"},"ch":{"a9.V":"r"},"aQ":{"R":[]},"b6":{"R":[]},"cK":{"R":[]},"cJ":{"R":[]},"o":{"h":[],"v":[],"j":[]},"an":{"h":[],"v":[],"j":[]},"h":{"v":[],"j":[]},"ac":{"h":[],"v":[],"j":[]},"bM":{"X":[]},"bN":{"X":[]},"bO":{"X":[]},"aa":{"n":[]},"aE":{"n":[]},"bq":{"n":[]},"br":{"n":[]},"bw":{"n":[]},"bx":{"n":[]},"bI":{"n":[]},"bJ":{"n":[]},"bS":{"n":[]},"bR":{"n":[]},"bT":{"n":[]},"bU":{"n":[]},"bv":{"n":[]},"bB":{"n":[]},"c0":{"n":[]},"ay":{"N":[]},"bs":{"N":[]},"x":{"N":[]},"bz":{"N":[]},"ab":{"N":[]},"c1":{"ev":[],"N":[]},"a_":{"dQ":[]},"c8":{"X":[]},"cz":{"X":[]}}'))
H.fV(v.typeUniverse,JSON.parse('{"bo":1,"aA":1,"aN":1,"c6":1,"bK":1,"bZ":1,"cw":1,"aM":1,"bL":2,"a9":2,"b5":1,"b3":1,"ba":1,"bE":1,"cn":1,"aF":1,"aC":1}'))
0
var u=(function rtii(){var t=H.eT
return{y:t("ah"),t:t("a5"),C:t("q"),z:t("c"),Z:t("aD"),b:t("w<D<I>>"),Q:t("w<R>"),E:t("w<N>"),m:t("w<n>"),R:t("w<X>"),s:t("w<r>"),n:t("w<I>"),r:t("w<@>"),T:t("aH"),g:t("W"),p:t("bG<@>"),e:t("aO<r,r>"),P:t("M"),K:t("u"),q:t("dX<S>"),Y:t("an"),N:t("r"),u:t("h"),v:t("ac"),f:t("ao"),B:t("ev"),o:t("aq"),x:t("ar"),w:t("av"),i:t("I"),D:t("@"),S:t("hC"),A:t("0&*"),_:t("u*"),O:t("el<M>?"),X:t("u?"),H:t("S")}})();(function constants(){var t=hunkHelpers.makeConstList
C.o=W.a5.prototype
C.x=J.z.prototype
C.c=J.w.prototype
C.b=J.aG.prototype
C.y=J.aH.prototype
C.a=J.aI.prototype
C.j=J.a7.prototype
C.z=J.W.prototype
C.l=J.bQ.prototype
C.m=P.ac.prototype
C.f=J.aq.prototype
C.G=W.a1.prototype
C.n=W.b_.prototype
C.h=function getTagFallback(o) {
  var s = Object.prototype.toString.call(o);
  return s.substring(8, s.length - 1);
}
C.p=function() {
  var toStringFunction = Object.prototype.toString;
  function getTag(o) {
    var s = toStringFunction.call(o);
    return s.substring(8, s.length - 1);
  }
  function getUnknownTag(object, tag) {
    if (/^HTML[A-Z].*Element$/.test(tag)) {
      var name = toStringFunction.call(object);
      if (name == "[object Object]") return null;
      return "HTMLElement";
    }
  }
  function getUnknownTagGenericBrowser(object, tag) {
    if (self.HTMLElement && object instanceof HTMLElement) return "HTMLElement";
    return getUnknownTag(object, tag);
  }
  function prototypeForTag(tag) {
    if (typeof window == "undefined") return null;
    if (typeof window[tag] == "undefined") return null;
    var constructor = window[tag];
    if (typeof constructor != "function") return null;
    return constructor.prototype;
  }
  function discriminator(tag) { return null; }
  var isBrowser = typeof navigator == "object";
  return {
    getTag: getTag,
    getUnknownTag: isBrowser ? getUnknownTagGenericBrowser : getUnknownTag,
    prototypeForTag: prototypeForTag,
    discriminator: discriminator };
}
C.v=function(getTagFallback) {
  return function(hooks) {
    if (typeof navigator != "object") return hooks;
    var ua = navigator.userAgent;
    if (ua.indexOf("DumpRenderTree") >= 0) return hooks;
    if (ua.indexOf("Chrome") >= 0) {
      function confirm(p) {
        return typeof window == "object" && window[p] && window[p].name == p;
      }
      if (confirm("Window") && confirm("HTMLElement")) return hooks;
    }
    hooks.getTag = getTagFallback;
  };
}
C.q=function(hooks) {
  if (typeof dartExperimentalFixupGetTag != "function") return hooks;
  hooks.getTag = dartExperimentalFixupGetTag(hooks.getTag);
}
C.r=function(hooks) {
  var getTag = hooks.getTag;
  var prototypeForTag = hooks.prototypeForTag;
  function getTagFixed(o) {
    var tag = getTag(o);
    if (tag == "Document") {
      if (!!o.xmlVersion) return "!Document";
      return "!HTMLDocument";
    }
    return tag;
  }
  function prototypeForTagFixed(tag) {
    if (tag == "Document") return null;
    return prototypeForTag(tag);
  }
  hooks.getTag = getTagFixed;
  hooks.prototypeForTag = prototypeForTagFixed;
}
C.u=function(hooks) {
  var userAgent = typeof navigator == "object" ? navigator.userAgent : "";
  if (userAgent.indexOf("Firefox") == -1) return hooks;
  var getTag = hooks.getTag;
  var quickMap = {
    "BeforeUnloadEvent": "Event",
    "DataTransfer": "Clipboard",
    "GeoGeolocation": "Geolocation",
    "Location": "!Location",
    "WorkerMessageEvent": "MessageEvent",
    "XMLDocument": "!Document"};
  function getTagFirefox(o) {
    var tag = getTag(o);
    return quickMap[tag] || tag;
  }
  hooks.getTag = getTagFirefox;
}
C.t=function(hooks) {
  var userAgent = typeof navigator == "object" ? navigator.userAgent : "";
  if (userAgent.indexOf("Trident/") == -1) return hooks;
  var getTag = hooks.getTag;
  var quickMap = {
    "BeforeUnloadEvent": "Event",
    "DataTransfer": "Clipboard",
    "HTMLDDElement": "HTMLElement",
    "HTMLDTElement": "HTMLElement",
    "HTMLPhraseElement": "HTMLElement",
    "Position": "Geoposition"
  };
  function getTagIE(o) {
    var tag = getTag(o);
    var newTag = quickMap[tag];
    if (newTag) return newTag;
    if (tag == "Object") {
      if (window.DataView && (o instanceof window.DataView)) return "DataView";
    }
    return tag;
  }
  function prototypeForTagIE(tag) {
    var constructor = window[tag];
    if (constructor == null) return null;
    return constructor.prototype;
  }
  hooks.getTag = getTagIE;
  hooks.prototypeForTag = prototypeForTagIE;
}
C.i=function(hooks) { return hooks; }

C.d=new P.dt()
C.w=new W.cM()
C.A=H.d(t(["*::class","*::dir","*::draggable","*::hidden","*::id","*::inert","*::itemprop","*::itemref","*::itemscope","*::lang","*::spellcheck","*::title","*::translate","A::accesskey","A::coords","A::hreflang","A::name","A::shape","A::tabindex","A::target","A::type","AREA::accesskey","AREA::alt","AREA::coords","AREA::nohref","AREA::shape","AREA::tabindex","AREA::target","AUDIO::controls","AUDIO::loop","AUDIO::mediagroup","AUDIO::muted","AUDIO::preload","BDO::dir","BODY::alink","BODY::bgcolor","BODY::link","BODY::text","BODY::vlink","BR::clear","BUTTON::accesskey","BUTTON::disabled","BUTTON::name","BUTTON::tabindex","BUTTON::type","BUTTON::value","CANVAS::height","CANVAS::width","CAPTION::align","COL::align","COL::char","COL::charoff","COL::span","COL::valign","COL::width","COLGROUP::align","COLGROUP::char","COLGROUP::charoff","COLGROUP::span","COLGROUP::valign","COLGROUP::width","COMMAND::checked","COMMAND::command","COMMAND::disabled","COMMAND::label","COMMAND::radiogroup","COMMAND::type","DATA::value","DEL::datetime","DETAILS::open","DIR::compact","DIV::align","DL::compact","FIELDSET::disabled","FONT::color","FONT::face","FONT::size","FORM::accept","FORM::autocomplete","FORM::enctype","FORM::method","FORM::name","FORM::novalidate","FORM::target","FRAME::name","H1::align","H2::align","H3::align","H4::align","H5::align","H6::align","HR::align","HR::noshade","HR::size","HR::width","HTML::version","IFRAME::align","IFRAME::frameborder","IFRAME::height","IFRAME::marginheight","IFRAME::marginwidth","IFRAME::width","IMG::align","IMG::alt","IMG::border","IMG::height","IMG::hspace","IMG::ismap","IMG::name","IMG::usemap","IMG::vspace","IMG::width","INPUT::accept","INPUT::accesskey","INPUT::align","INPUT::alt","INPUT::autocomplete","INPUT::autofocus","INPUT::checked","INPUT::disabled","INPUT::inputmode","INPUT::ismap","INPUT::list","INPUT::max","INPUT::maxlength","INPUT::min","INPUT::multiple","INPUT::name","INPUT::placeholder","INPUT::readonly","INPUT::required","INPUT::size","INPUT::step","INPUT::tabindex","INPUT::type","INPUT::usemap","INPUT::value","INS::datetime","KEYGEN::disabled","KEYGEN::keytype","KEYGEN::name","LABEL::accesskey","LABEL::for","LEGEND::accesskey","LEGEND::align","LI::type","LI::value","LINK::sizes","MAP::name","MENU::compact","MENU::label","MENU::type","METER::high","METER::low","METER::max","METER::min","METER::value","OBJECT::typemustmatch","OL::compact","OL::reversed","OL::start","OL::type","OPTGROUP::disabled","OPTGROUP::label","OPTION::disabled","OPTION::label","OPTION::selected","OPTION::value","OUTPUT::for","OUTPUT::name","P::align","PRE::width","PROGRESS::max","PROGRESS::min","PROGRESS::value","SELECT::autocomplete","SELECT::disabled","SELECT::multiple","SELECT::name","SELECT::required","SELECT::size","SELECT::tabindex","SOURCE::type","TABLE::align","TABLE::bgcolor","TABLE::border","TABLE::cellpadding","TABLE::cellspacing","TABLE::frame","TABLE::rules","TABLE::summary","TABLE::width","TBODY::align","TBODY::char","TBODY::charoff","TBODY::valign","TD::abbr","TD::align","TD::axis","TD::bgcolor","TD::char","TD::charoff","TD::colspan","TD::headers","TD::height","TD::nowrap","TD::rowspan","TD::scope","TD::valign","TD::width","TEXTAREA::accesskey","TEXTAREA::autocomplete","TEXTAREA::cols","TEXTAREA::disabled","TEXTAREA::inputmode","TEXTAREA::name","TEXTAREA::placeholder","TEXTAREA::readonly","TEXTAREA::required","TEXTAREA::rows","TEXTAREA::tabindex","TEXTAREA::wrap","TFOOT::align","TFOOT::char","TFOOT::charoff","TFOOT::valign","TH::abbr","TH::align","TH::axis","TH::bgcolor","TH::char","TH::charoff","TH::colspan","TH::headers","TH::height","TH::nowrap","TH::rowspan","TH::scope","TH::valign","TH::width","THEAD::align","THEAD::char","THEAD::charoff","THEAD::valign","TR::align","TR::bgcolor","TR::char","TR::charoff","TR::valign","TRACK::default","TRACK::kind","TRACK::label","TRACK::srclang","UL::compact","UL::type","VIDEO::controls","VIDEO::height","VIDEO::loop","VIDEO::mediagroup","VIDEO::muted","VIDEO::preload","VIDEO::width"]),u.s)
C.B=H.d(t(["HEAD","AREA","BASE","BASEFONT","BR","COL","COLGROUP","EMBED","FRAME","FRAMESET","HR","IMAGE","IMG","INPUT","ISINDEX","LINK","META","PARAM","SOURCE","STYLE","TITLE","WBR"]),u.s)
C.C=H.d(t([]),u.s)
C.k=H.d(t(["bind","if","ref","repeat","syntax"]),u.s)
C.e=H.d(t(["A::href","AREA::href","BLOCKQUOTE::cite","BODY::background","COMMAND::icon","DEL::cite","FORM::action","IMG::src","INPUT::src","INS::cite","Q::cite","VIDEO::poster"]),u.s)
C.D=new V.al(0,!1,!1,!1)
C.E=new V.al(0,!1,!1,!0)
C.F=new V.al(0,!0,!1,!1)})();(function staticFields(){$.dq=null
$.V=0
$.aw=null
$.eg=null
$.eU=null
$.eR=null
$.eY=null
$.dG=null
$.dM=null
$.ea=null
$.at=null
$.bc=null
$.bd=null
$.e5=!1
$.c7=C.d
$.H=H.d([],H.eT("w<u>"))
$.a0=null
$.dR=null
$.ek=null
$.ej=null
$.cr=P.fw(u.N,u.Z)})();(function lazyInitializers(){var t=hunkHelpers.lazyFinal
t($,"hV","f0",function(){return H.hv("_$dart_dartClosure")})
t($,"i1","f1",function(){return H.Y(H.dh({
toString:function(){return"$receiver$"}}))})
t($,"i2","f2",function(){return H.Y(H.dh({$method$:null,
toString:function(){return"$receiver$"}}))})
t($,"i3","f3",function(){return H.Y(H.dh(null))})
t($,"i4","f4",function(){return H.Y(function(){var $argumentsExpr$="$arguments$"
try{null.$method$($argumentsExpr$)}catch(s){return s.message}}())})
t($,"i7","f7",function(){return H.Y(H.dh(void 0))})
t($,"i8","f8",function(){return H.Y(function(){var $argumentsExpr$="$arguments$"
try{(void 0).$method$($argumentsExpr$)}catch(s){return s.message}}())})
t($,"i6","f6",function(){return H.Y(H.ex(null))})
t($,"i5","f5",function(){return H.Y(function(){try{null.$method$}catch(s){return s.message}}())})
t($,"ia","fa",function(){return H.Y(H.ex(void 0))})
t($,"i9","f9",function(){return H.Y(function(){try{(void 0).$method$}catch(s){return s.message}}())})
t($,"ib","ec",function(){return P.fD()})
t($,"ic","fb",function(){return P.eo(["A","ABBR","ACRONYM","ADDRESS","AREA","ARTICLE","ASIDE","AUDIO","B","BDI","BDO","BIG","BLOCKQUOTE","BR","BUTTON","CANVAS","CAPTION","CENTER","CITE","CODE","COL","COLGROUP","COMMAND","DATA","DATALIST","DD","DEL","DETAILS","DFN","DIR","DIV","DL","DT","EM","FIELDSET","FIGCAPTION","FIGURE","FONT","FOOTER","FORM","H1","H2","H3","H4","H5","H6","HEADER","HGROUP","HR","I","IFRAME","IMG","INPUT","INS","KBD","LABEL","LEGEND","LI","MAP","MARK","MENU","METER","NAV","NOBR","OL","OPTGROUP","OPTION","OUTPUT","P","PRE","PROGRESS","Q","S","SAMP","SECTION","SELECT","SMALL","SOURCE","SPAN","STRIKE","STRONG","SUB","SUMMARY","SUP","TABLE","TBODY","TD","TEXTAREA","TFOOT","TH","THEAD","TIME","TR","TRACK","TT","U","UL","VAR","VIDEO","WBR"],u.N)})})();(function nativeSupport(){!function(){var t=function(a){var n={}
n[a]=1
return Object.keys(hunkHelpers.convertToFastObject(n))[0]}
v.getIsolateTag=function(a){return t("___dart_"+a+v.isolateTag)}
var s="___dart_isolate_tags_"
var r=Object[s]||(Object[s]=Object.create(null))
var q="_ZxYxX"
for(var p=0;;p++){var o=t(q+"_"+p+"_")
if(!(o in r)){r[o]=1
v.isolateTag=o
break}}v.dispatchPropertyName=v.getIsolateTag("dispatch_record")}()
hunkHelpers.setOrUpdateInterceptorsByTag({DOMError:J.z,DOMImplementation:J.z,MediaError:J.z,Navigator:J.z,NavigatorConcurrentHardware:J.z,NavigatorUserMediaError:J.z,OverconstrainedError:J.z,PositionError:J.z,Range:J.z,SVGMatrix:J.z,SVGPoint:J.z,SQLError:J.z,HTMLAudioElement:W.e,HTMLBRElement:W.e,HTMLButtonElement:W.e,HTMLCanvasElement:W.e,HTMLContentElement:W.e,HTMLDListElement:W.e,HTMLDataElement:W.e,HTMLDataListElement:W.e,HTMLDetailsElement:W.e,HTMLDialogElement:W.e,HTMLDivElement:W.e,HTMLEmbedElement:W.e,HTMLFieldSetElement:W.e,HTMLHRElement:W.e,HTMLHeadElement:W.e,HTMLHeadingElement:W.e,HTMLHtmlElement:W.e,HTMLIFrameElement:W.e,HTMLImageElement:W.e,HTMLInputElement:W.e,HTMLLIElement:W.e,HTMLLabelElement:W.e,HTMLLegendElement:W.e,HTMLLinkElement:W.e,HTMLMapElement:W.e,HTMLMediaElement:W.e,HTMLMenuElement:W.e,HTMLMetaElement:W.e,HTMLMeterElement:W.e,HTMLModElement:W.e,HTMLOListElement:W.e,HTMLObjectElement:W.e,HTMLOptGroupElement:W.e,HTMLOptionElement:W.e,HTMLOutputElement:W.e,HTMLParagraphElement:W.e,HTMLParamElement:W.e,HTMLPictureElement:W.e,HTMLPreElement:W.e,HTMLProgressElement:W.e,HTMLQuoteElement:W.e,HTMLScriptElement:W.e,HTMLShadowElement:W.e,HTMLSlotElement:W.e,HTMLSourceElement:W.e,HTMLSpanElement:W.e,HTMLStyleElement:W.e,HTMLTableCaptionElement:W.e,HTMLTableCellElement:W.e,HTMLTableDataCellElement:W.e,HTMLTableHeaderCellElement:W.e,HTMLTableColElement:W.e,HTMLTableElement:W.e,HTMLTableRowElement:W.e,HTMLTableSectionElement:W.e,HTMLTextAreaElement:W.e,HTMLTimeElement:W.e,HTMLTitleElement:W.e,HTMLTrackElement:W.e,HTMLUListElement:W.e,HTMLUnknownElement:W.e,HTMLVideoElement:W.e,HTMLDirectoryElement:W.e,HTMLFontElement:W.e,HTMLFrameElement:W.e,HTMLFrameSetElement:W.e,HTMLMarqueeElement:W.e,HTMLElement:W.e,HTMLAnchorElement:W.bm,HTMLAreaElement:W.bn,HTMLBaseElement:W.ah,HTMLBodyElement:W.a5,CDATASection:W.Q,CharacterData:W.Q,Comment:W.Q,ProcessingInstruction:W.Q,Text:W.Q,CSSStyleDeclaration:W.ax,MSStyleCSSProperties:W.ax,CSS2Properties:W.ax,DOMException:W.cY,DOMRectReadOnly:W.az,Element:W.v,AbortPaymentEvent:W.c,AnimationEvent:W.c,AnimationPlaybackEvent:W.c,ApplicationCacheErrorEvent:W.c,BackgroundFetchClickEvent:W.c,BackgroundFetchEvent:W.c,BackgroundFetchFailEvent:W.c,BackgroundFetchedEvent:W.c,BeforeInstallPromptEvent:W.c,BeforeUnloadEvent:W.c,BlobEvent:W.c,CanMakePaymentEvent:W.c,ClipboardEvent:W.c,CloseEvent:W.c,CustomEvent:W.c,DeviceMotionEvent:W.c,DeviceOrientationEvent:W.c,ErrorEvent:W.c,ExtendableEvent:W.c,ExtendableMessageEvent:W.c,FetchEvent:W.c,FontFaceSetLoadEvent:W.c,ForeignFetchEvent:W.c,GamepadEvent:W.c,HashChangeEvent:W.c,InstallEvent:W.c,MediaEncryptedEvent:W.c,MediaKeyMessageEvent:W.c,MediaQueryListEvent:W.c,MediaStreamEvent:W.c,MediaStreamTrackEvent:W.c,MessageEvent:W.c,MIDIConnectionEvent:W.c,MIDIMessageEvent:W.c,MutationEvent:W.c,NotificationEvent:W.c,PageTransitionEvent:W.c,PaymentRequestEvent:W.c,PaymentRequestUpdateEvent:W.c,PopStateEvent:W.c,PresentationConnectionAvailableEvent:W.c,PresentationConnectionCloseEvent:W.c,ProgressEvent:W.c,PromiseRejectionEvent:W.c,PushEvent:W.c,RTCDataChannelEvent:W.c,RTCDTMFToneChangeEvent:W.c,RTCPeerConnectionIceEvent:W.c,RTCTrackEvent:W.c,SecurityPolicyViolationEvent:W.c,SensorErrorEvent:W.c,SpeechRecognitionError:W.c,SpeechRecognitionEvent:W.c,SpeechSynthesisEvent:W.c,StorageEvent:W.c,SyncEvent:W.c,TrackEvent:W.c,TransitionEvent:W.c,WebKitTransitionEvent:W.c,VRDeviceEvent:W.c,VRDisplayEvent:W.c,VRSessionEvent:W.c,MojoInterfaceRequestEvent:W.c,ResourceProgressEvent:W.c,USBConnectionEvent:W.c,IDBVersionChangeEvent:W.c,AudioProcessingEvent:W.c,OfflineAudioCompletionEvent:W.c,WebGLContextEvent:W.c,Event:W.c,InputEvent:W.c,SubmitEvent:W.c,EventTarget:W.by,HTMLFormElement:W.bA,Location:W.d3,PointerEvent:W.K,MouseEvent:W.K,DragEvent:W.K,Document:W.j,DocumentFragment:W.j,HTMLDocument:W.j,ShadowRoot:W.j,XMLDocument:W.j,DocumentType:W.j,Node:W.j,NodeList:W.aP,RadioNodeList:W.aP,HTMLSelectElement:W.bW,HTMLTemplateElement:W.ao,CompositionEvent:W.P,FocusEvent:W.P,KeyboardEvent:W.P,TextEvent:W.P,TouchEvent:W.P,UIEvent:W.P,WheelEvent:W.a1,Window:W.b_,DOMWindow:W.b_,Attr:W.ar,ClientRect:W.b0,DOMRect:W.b0,NamedNodeMap:W.b4,MozNamedAttrMap:W.b4,SVGAElement:P.o,SVGCircleElement:P.o,SVGClipPathElement:P.o,SVGDefsElement:P.o,SVGEllipseElement:P.o,SVGForeignObjectElement:P.o,SVGGElement:P.o,SVGGeometryElement:P.o,SVGImageElement:P.o,SVGLineElement:P.o,SVGPathElement:P.o,SVGPolygonElement:P.o,SVGPolylineElement:P.o,SVGRectElement:P.o,SVGSwitchElement:P.o,SVGTSpanElement:P.o,SVGTextContentElement:P.o,SVGTextElement:P.o,SVGTextPathElement:P.o,SVGTextPositioningElement:P.o,SVGUseElement:P.o,SVGGraphicsElement:P.o,SVGScriptElement:P.an,SVGAnimateElement:P.h,SVGAnimateMotionElement:P.h,SVGAnimateTransformElement:P.h,SVGAnimationElement:P.h,SVGDescElement:P.h,SVGDiscardElement:P.h,SVGFEBlendElement:P.h,SVGFEColorMatrixElement:P.h,SVGFEComponentTransferElement:P.h,SVGFECompositeElement:P.h,SVGFEConvolveMatrixElement:P.h,SVGFEDiffuseLightingElement:P.h,SVGFEDisplacementMapElement:P.h,SVGFEDistantLightElement:P.h,SVGFEFloodElement:P.h,SVGFEFuncAElement:P.h,SVGFEFuncBElement:P.h,SVGFEFuncGElement:P.h,SVGFEFuncRElement:P.h,SVGFEGaussianBlurElement:P.h,SVGFEImageElement:P.h,SVGFEMergeElement:P.h,SVGFEMergeNodeElement:P.h,SVGFEMorphologyElement:P.h,SVGFEOffsetElement:P.h,SVGFEPointLightElement:P.h,SVGFESpecularLightingElement:P.h,SVGFESpotLightElement:P.h,SVGFETileElement:P.h,SVGFETurbulenceElement:P.h,SVGFilterElement:P.h,SVGLinearGradientElement:P.h,SVGMarkerElement:P.h,SVGMaskElement:P.h,SVGMetadataElement:P.h,SVGPatternElement:P.h,SVGRadialGradientElement:P.h,SVGSetElement:P.h,SVGStopElement:P.h,SVGStyleElement:P.h,SVGSymbolElement:P.h,SVGTitleElement:P.h,SVGViewElement:P.h,SVGGradientElement:P.h,SVGComponentTransferFunctionElement:P.h,SVGFEDropShadowElement:P.h,SVGMPathElement:P.h,SVGElement:P.h,SVGSVGElement:P.ac})
hunkHelpers.setOrUpdateLeafTags({DOMError:true,DOMImplementation:true,MediaError:true,Navigator:true,NavigatorConcurrentHardware:true,NavigatorUserMediaError:true,OverconstrainedError:true,PositionError:true,Range:true,SVGMatrix:true,SVGPoint:true,SQLError:true,HTMLAudioElement:true,HTMLBRElement:true,HTMLButtonElement:true,HTMLCanvasElement:true,HTMLContentElement:true,HTMLDListElement:true,HTMLDataElement:true,HTMLDataListElement:true,HTMLDetailsElement:true,HTMLDialogElement:true,HTMLDivElement:true,HTMLEmbedElement:true,HTMLFieldSetElement:true,HTMLHRElement:true,HTMLHeadElement:true,HTMLHeadingElement:true,HTMLHtmlElement:true,HTMLIFrameElement:true,HTMLImageElement:true,HTMLInputElement:true,HTMLLIElement:true,HTMLLabelElement:true,HTMLLegendElement:true,HTMLLinkElement:true,HTMLMapElement:true,HTMLMediaElement:true,HTMLMenuElement:true,HTMLMetaElement:true,HTMLMeterElement:true,HTMLModElement:true,HTMLOListElement:true,HTMLObjectElement:true,HTMLOptGroupElement:true,HTMLOptionElement:true,HTMLOutputElement:true,HTMLParagraphElement:true,HTMLParamElement:true,HTMLPictureElement:true,HTMLPreElement:true,HTMLProgressElement:true,HTMLQuoteElement:true,HTMLScriptElement:true,HTMLShadowElement:true,HTMLSlotElement:true,HTMLSourceElement:true,HTMLSpanElement:true,HTMLStyleElement:true,HTMLTableCaptionElement:true,HTMLTableCellElement:true,HTMLTableDataCellElement:true,HTMLTableHeaderCellElement:true,HTMLTableColElement:true,HTMLTableElement:true,HTMLTableRowElement:true,HTMLTableSectionElement:true,HTMLTextAreaElement:true,HTMLTimeElement:true,HTMLTitleElement:true,HTMLTrackElement:true,HTMLUListElement:true,HTMLUnknownElement:true,HTMLVideoElement:true,HTMLDirectoryElement:true,HTMLFontElement:true,HTMLFrameElement:true,HTMLFrameSetElement:true,HTMLMarqueeElement:true,HTMLElement:false,HTMLAnchorElement:true,HTMLAreaElement:true,HTMLBaseElement:true,HTMLBodyElement:true,CDATASection:true,CharacterData:true,Comment:true,ProcessingInstruction:true,Text:true,CSSStyleDeclaration:true,MSStyleCSSProperties:true,CSS2Properties:true,DOMException:true,DOMRectReadOnly:false,Element:false,AbortPaymentEvent:true,AnimationEvent:true,AnimationPlaybackEvent:true,ApplicationCacheErrorEvent:true,BackgroundFetchClickEvent:true,BackgroundFetchEvent:true,BackgroundFetchFailEvent:true,BackgroundFetchedEvent:true,BeforeInstallPromptEvent:true,BeforeUnloadEvent:true,BlobEvent:true,CanMakePaymentEvent:true,ClipboardEvent:true,CloseEvent:true,CustomEvent:true,DeviceMotionEvent:true,DeviceOrientationEvent:true,ErrorEvent:true,ExtendableEvent:true,ExtendableMessageEvent:true,FetchEvent:true,FontFaceSetLoadEvent:true,ForeignFetchEvent:true,GamepadEvent:true,HashChangeEvent:true,InstallEvent:true,MediaEncryptedEvent:true,MediaKeyMessageEvent:true,MediaQueryListEvent:true,MediaStreamEvent:true,MediaStreamTrackEvent:true,MessageEvent:true,MIDIConnectionEvent:true,MIDIMessageEvent:true,MutationEvent:true,NotificationEvent:true,PageTransitionEvent:true,PaymentRequestEvent:true,PaymentRequestUpdateEvent:true,PopStateEvent:true,PresentationConnectionAvailableEvent:true,PresentationConnectionCloseEvent:true,ProgressEvent:true,PromiseRejectionEvent:true,PushEvent:true,RTCDataChannelEvent:true,RTCDTMFToneChangeEvent:true,RTCPeerConnectionIceEvent:true,RTCTrackEvent:true,SecurityPolicyViolationEvent:true,SensorErrorEvent:true,SpeechRecognitionError:true,SpeechRecognitionEvent:true,SpeechSynthesisEvent:true,StorageEvent:true,SyncEvent:true,TrackEvent:true,TransitionEvent:true,WebKitTransitionEvent:true,VRDeviceEvent:true,VRDisplayEvent:true,VRSessionEvent:true,MojoInterfaceRequestEvent:true,ResourceProgressEvent:true,USBConnectionEvent:true,IDBVersionChangeEvent:true,AudioProcessingEvent:true,OfflineAudioCompletionEvent:true,WebGLContextEvent:true,Event:false,InputEvent:false,SubmitEvent:false,EventTarget:false,HTMLFormElement:true,Location:true,PointerEvent:true,MouseEvent:false,DragEvent:false,Document:true,DocumentFragment:true,HTMLDocument:true,ShadowRoot:true,XMLDocument:true,DocumentType:true,Node:false,NodeList:true,RadioNodeList:true,HTMLSelectElement:true,HTMLTemplateElement:true,CompositionEvent:true,FocusEvent:true,KeyboardEvent:true,TextEvent:true,TouchEvent:true,UIEvent:false,WheelEvent:true,Window:true,DOMWindow:true,Attr:true,ClientRect:true,DOMRect:true,NamedNodeMap:true,MozNamedAttrMap:true,SVGAElement:true,SVGCircleElement:true,SVGClipPathElement:true,SVGDefsElement:true,SVGEllipseElement:true,SVGForeignObjectElement:true,SVGGElement:true,SVGGeometryElement:true,SVGImageElement:true,SVGLineElement:true,SVGPathElement:true,SVGPolygonElement:true,SVGPolylineElement:true,SVGRectElement:true,SVGSwitchElement:true,SVGTSpanElement:true,SVGTextContentElement:true,SVGTextElement:true,SVGTextPathElement:true,SVGTextPositioningElement:true,SVGUseElement:true,SVGGraphicsElement:false,SVGScriptElement:true,SVGAnimateElement:true,SVGAnimateMotionElement:true,SVGAnimateTransformElement:true,SVGAnimationElement:true,SVGDescElement:true,SVGDiscardElement:true,SVGFEBlendElement:true,SVGFEColorMatrixElement:true,SVGFEComponentTransferElement:true,SVGFECompositeElement:true,SVGFEConvolveMatrixElement:true,SVGFEDiffuseLightingElement:true,SVGFEDisplacementMapElement:true,SVGFEDistantLightElement:true,SVGFEFloodElement:true,SVGFEFuncAElement:true,SVGFEFuncBElement:true,SVGFEFuncGElement:true,SVGFEFuncRElement:true,SVGFEGaussianBlurElement:true,SVGFEImageElement:true,SVGFEMergeElement:true,SVGFEMergeNodeElement:true,SVGFEMorphologyElement:true,SVGFEOffsetElement:true,SVGFEPointLightElement:true,SVGFESpecularLightingElement:true,SVGFESpotLightElement:true,SVGFETileElement:true,SVGFETurbulenceElement:true,SVGFilterElement:true,SVGLinearGradientElement:true,SVGMarkerElement:true,SVGMaskElement:true,SVGMetadataElement:true,SVGPatternElement:true,SVGRadialGradientElement:true,SVGSetElement:true,SVGStopElement:true,SVGStyleElement:true,SVGSymbolElement:true,SVGTitleElement:true,SVGViewElement:true,SVGGradientElement:true,SVGComponentTransferFunctionElement:true,SVGFEDropShadowElement:true,SVGMPathElement:true,SVGElement:false,SVGSVGElement:true})})()
convertAllToFastObject(w)
convertToFastObject($);(function(a){if(typeof document==="undefined"){a(null)
return}if(typeof document.currentScript!="undefined"){a(document.currentScript)
return}var t=document.scripts
function onLoad(b){for(var r=0;r<t.length;++r)t[r].removeEventListener("load",onLoad,false)
a(b.target)}for(var s=0;s<t.length;++s)t[s].addEventListener("load",onLoad,false)})(function(a){v.currentScript=a
var t=F.hH
if(typeof dartMainRunner==="function")dartMainRunner(t,[])
else t([])})})()
//# sourceMappingURL=main.dart.js.map

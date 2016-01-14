local class = require 'gabe.class'
local they = it

describe("classes", function()
	they("can be constructed", function()
		local K = class 'k'
		function K:method()
		end
		K.field = true
		assert.equal(type(K.method), 'function')
		assert.equal(type(K.field), 'boolean')
	end)

	they("can create objects", function()
		local K = class 'k'
		function K:init(a)
			self.a = a
		end
		assert.equal(K.new(true).a, true)
		assert.equal(K.new(false).a, false)
		assert.equal(K.new("string").a, "string")
	end)

	they("report their type", function()
		local K = class 'classname'
		local K2 = class 'classname2'
		assert.equal(class.xtype(K), 'classname')
		assert.equal(class.xtype(K2), 'classname2')
	end)
end)

describe("mixins", function()
	it("add fields to classes", function()
		local K = class 'K'
		local mixin = { field = "mixed-in" }
		class.mixin(K, mixin)
		assert.equal(K.field, "mixed-in")
	end)

	it("doesn't override existing fields", function()
		local K = class 'K'
		K.field = "unmixed"
		local mixin = { field = "mixed-in", field2 = "mixed-in" }
		class.mixin(K, mixin)
		assert.equal(K.field,  "unmixed")
		assert.equal(K.field2, "mixed-in")
	end)

	it("juxtapose functions that have the same name", function()
		local K = class 'K'
		local a, b = false
		function K.thing() a = true end
		local mixin = {}
		function mixin.thing() b = true end
		class.mixin(K, mixin)
		K.thing()
		assert.equal(a, true)
		assert.equal(b, true)
	end)

	it("can also be classes", function()
		local K = class 'K'
		local M = class 'M'

		assert.equal(class.xtype(K), 'K')
		assert.equal(class.xtype(M), 'M')

		class.mixin(K, M)

		assert.equal(class.xtype(K), 'K')
		assert.equal(class.xtype(M), 'M')

		assert(class.xtype(K.new()), 'K')
		assert(class.xtype(M.new()), 'M')
	end)

	it("will report themselves by name when they're a class", function()
		local K = class 'K'
		local M = class 'M'
		class.mixin(K, M)
		assert.truthy(class.is(K,       'K'))
		assert.truthy(class.is(K,       'M'))
		assert.truthy(class.is(K.new(), 'K'))
		assert.truthy(class.is(K.new(), 'M'))
	end)
end)

describe("objects", function()
	it("have a class name", function()
		local K = class 'classname'
		assert.equal(class.xtype(K.new()), 'classname')
	end)

	it("shadow class fields", function()
		local Klass = class 'classname'
		Klass.field = "global"
		local klass = Klass.new()
		klass.field = "local"
		assert.equal(Klass.field, "global")
		assert.equal(klass.field, "local")
	end)
end)

describe("fn-refs", function()
	it("is a gabe object", function()
		local f = class.fn("gabe.class", 'xtype')
		assert.equal('function-ref', class.xtype(f))
	end)

	it("can be called",function()
		local f = class.fn("_G", 'type')
		assert.equal('string', f('a'))
		assert.equal('number', f(2))
	end)
end)

describe("method-refs", function()
	it("is a gabe object", function()
		local f = class.method(nil, "maymay")
		assert.equal('method-ref', class.xtype(f))
	end)
	it("can be called", function()
		local c = class 'c'
		function c:meme(arg)
			self.last = arg
			return arg + 1
		end
		local o = c.new()
		local f = class.method(o, 'meme')
		assert.equal(5, f(4))
		assert.equal(4, o.last)

		assert.equal(4, f(3))
		assert.equal(3, o.last)
	end)
end)

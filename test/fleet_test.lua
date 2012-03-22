package.path = package.path .. ";../src/?.lua;src/?.lua"

require "telescope"
require "fleet"

function table.compare(self, other)
  -- NOTE: the body of this function was taken and slightly adapted from
  --       Penlight (http://github.com/stevedonovan/Penlight)
  if #self ~= #other then return false end
  local visited = {}
  for i = 1, #self do
    local val, gotcha = self[i], nil
    for j = 1, #other do
      if not visited[j] then
        if (type(val) == 'table') then
          if (table.compare(val, other[j])) then
            gotcha = j
            break
          end
        else
          if val == other[j] then
            gotcha = j
            break
          end
        end
      end
    end
    if not gotcha then return false end
    visited[gotcha] = true
  end
  return true
end

make_assertion("table_values", "'%s' to have the same values as '%s'", table.compare)

context("FleetDB client", function()
  before(function()
    client = Fleet.new({ port=3400, timeout=1 })
    client:query{"delete", "records"}
  end)

  after(function()
    client:close()
  end)

  test("ping", function()
    assert_equal("pong", client:query{"ping"})
  end)

  test("write and read", function()
    assert_equal(1, client:query{"insert", "records", {id=3}})
    assert_table_values({{id=3}}, client:query{"select", "records"})
  end)

  test("expection", function()
    assert_error(function()
      client:query{"bogus"}
    end)
  end)

  test("connection refused", function()
    assert_error(function()
      Fleet.new({ port=3402 })
    end)
  end)

  context("with authorization", function()
    test("client auth success", function()
      local client = Fleet.new({ port=3401, password="pass" })
      assert_equal("pong", client:query{"ping"})
    end)

    test("client auth ommission", function()
      assert_error(function()
        local client = Fleet.new({ port=3401 })
        client:query{"ping"}
      end)
    end)

    test("client auth failure", function()
      assert_error(function()
        Fleet.new({ port=3401, password="notpass" })
      end)
    end)
  end)
end)

local Parse
do -- Main Functions
    function count(Table) 
        local n = 0
        for i, v in next, Table do 
            n = n + 1
        end
        return n
    end
    function Parse(Table) 
        whitespace = "    "
        ArrayStyle = "[%s]"
        amount = 1
        local TablesDumped = {[Table] = true}
        Close = "}"
        ValueClose = ""
        results = "{"
        function GenerateString(Value) 
            local UseString = true
            if type(Value) ~= "string" then 
                Value = ValueTypeLuaSec(Value)
            end
            local ListChange = {
                {from = "\\", to = "\\\\"},
                {from = "\"", to = "\\\""},
                {from = "\n", to = "\\n"},
                {from = "\a", to = "\\a"},
                {from = "\f", to = "\\f"},
                {from = "\b", to = "\\b"},
                {from = "\\J", to = "\\0"}
            }
            local FE = "\"%s\""
            local Val = {}
            Value:gsub(".", function(v)
                if v == "\0" then 
                    table.insert(Val, "")
                else
                    table.insert(Val, v)
                end
            end)
            Value = table.concat(Val)
            for i, v in next, ListChange do 
                Value = Value:gsub(v.from, v.to)
            end
            return FE:format(Value)
        end
        function ValueTypeLuaSec(value, useString)
            local ok = ""
            if typeof(value) == "string" then 
                if useString then 
                    ok = GenerateString(value)
                else
                    ok = value
                end
            elseif typeof(value) == "function" then 
                ok = "function() end"
            elseif typeof(value) == "CFrame" then
                ok = GeneratePositionValue("CFrame", value)
            elseif typeof(value) == "Vector3" then
                ok = GeneratePositionValue("Vector3", value)
            elseif typeof(value) == "UDim2" then
                ok = GeneratePositionValue("UDim2", value)
            elseif typeof(value) == "Vector2" then
                ok = GeneratePositionValue("Vector2", value)
            elseif typeof(value) == "userdata" then
                ok = "userdata"
            elseif typeof(value) == "table" then
                ok = "table"
            else
                ok = tostring(value)
            end
            return ok
        end
        function GeneratePositionValue(name, value) 
            local Str = "%s.new(%s)"
            Str = Str:format(name, tostring(value))
            return Str
        end
        function ValueTypeLua(value)
            local ok = ""
            if typeof(value) == "string" then 
                ok = GenerateString(value)
            elseif typeof(value) == "function" then 
                ok = "function() end"
            elseif typeof(value) == "CFrame" then
                ok = GeneratePositionValue("CFrame", value)
            elseif typeof(value) == "Vector3" then
                ok = GeneratePositionValue("Vector3", value)
            elseif typeof(value) == "UDim2" then
                ok = GeneratePositionValue("UDim2", value)
            elseif typeof(value) == "Vector2" then
                ok = GeneratePositionValue("Vector2", value)
            elseif typeof(value) == "userdata" then
                ok = GenerateString("userdata")
            elseif typeof(value) == "table" then
                ok = GenerateString("table")
            else
                ok = tostring(value)
            end
            return ok..ValueClose
        end
        function shouldUseBrackets(Value) 
            local should = false
            if type(Value) ~= "string" then 
                Value = ValueTypeLuaSec(Value)
            end
            if #Value:split(" ") > 1 then 
                should = true
            end
            if Value:find("\\", 1, true) then 
                should = true
            end
            return should
        end
        function TableValueTemplete(index) 
            local okhand = ""
            if shouldUseBrackets(index) then 
                okhand = ArrayStyle:format(GenerateString(index)) .." = "
            elseif type(index) == "number" then 
                okhand = ArrayStyle:format(index) .." = "
            else
                okhand = ValueTypeLuaSec(index) .." = "
            end
            return okhand
        end
        local function HasIndexNString(Val) 
            local indian = false
            local main = false
            local numberaaaa = false
            for i, v in next, Val do 
                if type(i) == "number" then 
                    indian = true
                end
                if type(i) == "string" then 
                    numberaaaa = true
                end
            end
            if indian and numberaaaa then 
                main = true
            end
            return main
        end
        function ValueTemplete(i, v, fat) 
            local okhand = ""
            if shouldUseBrackets(i) then 
                okhand = ArrayStyle:format(GenerateString(i)) .." = "..ValueTypeLua(v)
            elseif type(i) == "string" then 
                okhand = i .." = "..ValueTypeLua(v)
            elseif type(i) == "number" then 
                okhand = ArrayStyle:format(i) .." = " .. ValueTypeLua(v)
            else
                okhand = ValueTypeLuaSec(i) .." = "..ValueTypeLua(v)
            end
            local JOE = fat and "," or ""
            return okhand .. JOE
        end
        function HandleMoreList(NewTable) 
            local NewResults = "{"
            amount = amount + 1
            local Times = 0
            for i, v in pairs(NewTable) do 
                Times = Times + 1
                local JOE = Times ~= count(NewTable) and "," or ""
                if typeof(v) == "table" then 
                    if TablesDumped[v] then 
                        NewResults = NewResults.."\n"..whitespace:rep(amount)..TableValueTemplete(i) .. "{}"
                        continue
                    end
                    NewResults = NewResults.."\n"..whitespace:rep(amount)..TableValueTemplete(i)..HandleMoreList(v)..JOE
                    TablesDumped[v] = true
                else
                    NewResults = NewResults.."\n"..whitespace:rep(amount)..ValueTemplete(i, v, Times ~= count(NewTable))
                end
            end
            amount = amount - 1
            local indian = ""
            local JOE = Times ~= count(NewTable) and "," or ""
            if count(NewTable) == 0 then 
                indian = "{}"
            else
                indian = NewResults .. "\n" .. whitespace:rep(amount) .. Close
            end
            return indian .. JOE
        end
        local times = 0
        for i, v in pairs(Table) do
            times = times + 1
            local JOE = times ~= count(Table) and "," or ""
            if typeof(v) ~= "table" then
                results = results.."\n"..whitespace:rep(amount)..ValueTemplete(i, v, times ~= count(Table))
            else
                TablesDumped[v] = true
                results = results.."\n"..whitespace:rep(amount)..TableValueTemplete(i)..HandleMoreList(v)..JOE
            end
        end
        return results.."\n}"
    end
end

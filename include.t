local vnc=1
return function(file,ifs)
  local args=table.concat(ifs," ").." -include"..file
  local function replace(text)
    local tmp=os.tmpname()
    local file=io.open(tmp,"w")
    file:write("terra_start_marker{"..text.."}")
    file:close()
    local ret=io.popen("cpp "..args.." -P "..tmp,"r")
    local res=ret:read("*a")
    ret:close()
    --os.remove(tmp)
    return res:match("terra_start_marker{(.*)}")
  end
  local ret={}
  function ret.value(text,type)
    local vn="terra_value_"..vnc
    vnc=vnc+1
    return terralib.includecstring("const "..type.." "..vn.."="..replace(text)..";",ifs)[vn]:get()
  end
  return ret
end

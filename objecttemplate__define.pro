;+
;
;  Simple object template that, by default, allows you to use the dot
;  notation to modify object properties. This works the same way that
;  dictionaries and many ENVI objects operate.
;  
;  To use the template, you will simply need to replace all instances
;  of "objectTemplate" with the name of your object. This also means
;  that the name of the file will need to be updates as well.
;
; :Author: Zachary Norman - GitHub: znorman17
;-


;+
; :Description:
;    Init function for our object so that we can call the 
;    object directly as a function instead of needing to use
;    the obj_new() function
;
;
; :Author: Zachary Norman - GitHub: znorman17
;-
function objectTemplate::Init
  compile_opt idl2, hidden

  ;here you should initialize static object properties such as
  ;default values and the _initialize method can set properties
  ;that are based on user input or something else

  ;initialize our dynamic object properties
  self._Initialize

  ;we succeeded, so return one for a valid object
  return, 1
end

;+
; :Description:
;    Simple procedure to initialize all of the properties of the object
;    to their default values.
;
;
; :Author: Zachary Norman - GitHub: znorman17
;-
pro objectTemplate::_Initialize
  compile_opt idl2, hidden

end


;+
; :Description:
;    Object method for eny custom cleanup actions that we may need.
;
; :Author: Zachary Norman - GitHub: znorman17
;
;-
pro objectTemplate::Cleanup
  compile_opt idl2, hidden
  


end


;+
; :Description:
;    Get property method that works with the "dot" notation.
;
;
; :Keywords:
;    _REF_EXTRA: in, requried, type=assorted
;     Allowed properties are any object definition parameters.
;
; :Author: Zachary Norman - GitHub: znorman17
;-
pro objectTemplate::GetProperty, _REF_EXTRA=extra
  compile_opt idl2, hidden
  on_error, 2

  if (extra ne !NULL) then begin
    ;get self tag names, first three are related to IDL_Object and not needed
    properties = (tag_names(self))[3:*]

    ;check if property we are getting exists
    foreach property, strupcase(extra) do begin
      prop_idx = (where(property eq properties, is_prop))[0]
      ;property exists, return it
      if (is_prop eq 1) then begin
        currentvalue = self.(3 + prop_idx)

        case (1) of
          isa(currentvalue, 'list') OR isa(currentvalue, 'hash'):begin
            (scope_varfetch(property, /REF_EXTRA)) = currentvalue
          end

          (currentValue eq !NULL):begin
            (scope_varfetch(property, /REF_EXTRA)) = !NULL
          end

          isa(currentvalue, 'pointer'):begin
            (scope_varfetch(property, /REF_EXTRA)) = *currentvalue
          end

          else:begin
            (scope_varfetch(property, /REF_EXTRA)) = currentvalue
          end
        endcase
      endif else begin
        message, 'Property "' + property + '" is not a valid object property!'
      endelse
    endforeach
  end
end


; :Description:
;    Wrapper method for overloading implied print which uses the
;    same method as the _overloadPrint method.
;
;
; :Author: Zachary Norman - GitHub: znorman17
;-
function objectTemplate::_OverloadImpliedPrint, varname
  compile_opt idl2, hidden
  return, self->objectTemplate::_overloadPrint()
end


;+
; :Description:
;    Object method for overloading printing and getting some basic information
;    from our crop centers object.
;
;
; :Author: Zachary Norman - GitHub: znorman17
;-
function objectTemplate::_OverloadPrint
  compile_opt idl2, hidden
  tags = tag_names(self)
  sorted = sort(tags[3:*])
  output = list()

  ;determine the number of white spaces we need to add
  maxlen = max(strlen(tags)) + 6

  for k=0,n_elements(sorted)-1 do begin
    i = 3 + sorted[k]
    help, self.(i), OUTPUT=o
    split = strsplit(o, /EXTRACT)
    type = split[1]
    add = ''
    for j=0, maxlen-strlen(tags[i]) do add += ' '
    output.add, string(9b) + strupcase(tags[i]) + add + type

    case 1 of
      isa(self.(i), 'LIST'):begin
        help, self.(i), OUTPUT = o
        type = strjoin((strsplit(o, /EXTRACT))[1:*], ' ')
        output.add, string(9b) + string(9b) + type
      end
      isa(self.(i), 'HASH'):begin
        help, self.(i), OUTPUT = o
        type = strjoin((strsplit(o, /EXTRACT))[1:*], ' ')
        output.add, string(9b) + string(9b) + type
      end
      (self.(i) eq !NULL):begin
        output.add, string(9b) + string(9b) + '!NULL'
      end
      isa(self.(i), 'OBJREF'):begin
        printed = string(self.(i), /IMPLIED_PRINT)
        foreach line, printed do output.add, string(9b) + string(9b) + line
      end
      isa(self.(i), 'POINTER'):begin
        help, *(self.(i)), OUTPUT=o
        split = (strsplit(o, /EXTRACT))[1:-1]
        if isa(split, 'LIST') then split = split.toarray()
        type = strjoin(split[1:*], ' ')
        output.add, string(9b) + string(9b) + type
      end
      else:begin
        output.add, string(9b) + string(9b) + strjoin(strtrim(self.(i),2),'     ')
      end
    endcase
  endfor

  return, strjoin(output.toarray(), string(10b))
end

;+
; :Description:
;    Set property method that works with the ".dot" notation.
;
;
; :Keywords:
;    _REF_EXTRA: in, requried, type=assorted
;      Set keywords that match object properties in the object definition.
;
; :Author: Zachary Norman - GitHub: znorman17
;-
pro objectTemplate::SetProperty, _REF_EXTRA = extra
  compile_opt idl2, hidden
  on_error, 2

  if (extra ne !NULL) then begin
    ;get self tag names, first three are related to IDL_Object and not needed
    properties = (tag_names(self))[3:*]

    ;check if property we are setting exists
    foreach property, strupcase(extra) do begin
      prop_idx = (where(property eq properties , is_prop))[0]
      ;property exists, set it
      if (is_prop eq 1) then begin
        new_value = scope_varfetch(property, /REF_EXTRA)
        self._SetProperty, property, prop_idx, new_value
      endif else begin
        message, 'Property "' + property + '" is not a valid object property!'
      endelse
    endforeach
  endif
end

;+
; :Description:
;    Underlying set property method for this object so we don't have to have a
;    separate one at init and setproprty
;
; :Params:
;    property: name of property
;    prop_idx: index of property in structure
;    new_value: new value to replace the property with
;
;
;
; :Author: Zachary Norman - GitHub: znorman17
;-
pro objectTemplate::_SetProperty, property, prop_idx, new_value
  compile_opt idl2, hidden
  ;check if we have a pointer or not
  currentvalue = self.(3 + prop_idx)
  
  ;check if we are resetting a certain property which only works for
  ;strings, pointers, and objects otherwise structures are too strict
  ;to try and change the currentvalue
  if (new_value eq !NULL) then begin
    old_value = self.(3 + prop_idx)
    case 1 of
      (old_value.typecode eq 7):  self.(3 + prop_idx) = ''
      (old_value.typecode eq 10): self.(3 + prop_idx) = ptr_new()
      (old_value.typecode eq 11): self.(3 + prop_idx) = obj_new()
      else: begin
        message, 'Cannot set property "' + property + '" to !NULL because the datatype (' + strtrim(type,2) + ') will not allow it!'
      end
    endcase
    ;not setting the variable to !NULL
  endif else begin
    ;special checks for the property that we are setting
    ;these are examples for how to can create custom routines
    case property of
      'PROP1':begin

      end
      'PROP2':begin

      end
      else:begin
        ;default set property
        if ISA(currentvalue, 'pointer') then begin
          self.(3 + prop_idx) = ptr_new(new_value)
        endif else begin
          self.(3 + prop_idx) = new_value
        endelse
      endelse
    endcase
  endelse
end

;+
; :Description:
;    Object definition.
;
;
; :Author: Zachary Norman - znorman@harris.com
;-
pro objectTemplate__define
  compile_opt idl2

  compile_opt idl2, hidden
  struct = {ObjectTemplate, $
    inherits IDL_Object,$

  }
end

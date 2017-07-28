# ObjectTemplate

Simple object template that, by default, allows you to use the dot notation to modify object properties. This works the same way that dictionaries and many ENVI objects operate. The dot notation is the same method used to access information from IDL structures and looks like:

```
someObject = newObject()

;set an object property
someObject.PROPERTY1 = 42

;get an object property
print, someObject.PROPERTY42
```

These approaches are in line with modern object programming and is similar in syntax to other programming languages such as Python.

To use the template, you will simply need to replace all instances of "objectTemplate" with the name of your object. This also means that the name of the file will need to be updates as well.


## License

Licensed under MIT. See LICENSE.txt for more details.
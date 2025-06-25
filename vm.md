# VM
This interface is used to demonstrate the declaration of an interface by an example of manipulating the power-states of VMs. It shows how new datatypes can be declared and used in methods, and how errors are handled.
## Type definitions
### vm
```json
{ "name_description": "name_description", "name_label": "name_label" }
```
type `vm` = `struct { ... }`
This record contains the static properties of a VM object, such as the name, description and other useful bits and pieces. Runtime properties are part of some different record.
#### Members
 Name             | Type   | Description                
------------------|--------|----------------------------
 name_label       | string | The name of the VM.        
 name_description | string | The description of the VM. 
## Interface: `VM`
The VM interface is used to perform power-state operations on virtual machines. It doesn't do anything else in this implementation as it is purely being used as an example of how to declare an interface.
## Method: `start`
Start a VM. This method should be idempotent, and you can start the  same VM as many times as you like.

> Client

```json
{
  "method": "start",
  "params": [
    {
      "paused": true,
      "vm": {
        "name_description": "name_description",
        "name_label": "name_label"
      }
    }
  ],
  "id": 1
}
```

```ocaml
try
    let () = Client.start vm paused in
    ...
with Exn (errors str) -> ...

```

```python

# import necessary libraries if needed
# we assume that your library providing the client is called myclient and it provides a connect method
import myclient

if __name__ == "__main__":
    c = myclient.connect()
    results = c.VM.start({ vm: {"name_label": "string", "name_description": "string"}, paused: True })
    print(repr(results))
```

> Server

```json
null
```

```ocaml
try
    let () = Client.start vm paused in
    ...
with Exn (errors str) -> ...

```

```python

# import additional libraries if needed

class VM_myimplementation(VM_skeleton):
    # by default each method will return a Not_implemented error
    # ...

    def start(self, vm, paused):
        """
        Start a VM. This method should be idempotent, and you can start the
        same VM as many times as you like.
        """
    # ...
```


 Name   | Direction | Type | Description                    
--------|-----------|------|--------------------------------
 vm     | in        | vm   | Example structure              
 paused | in        | bool | Start the VM in a paused state 
## Errors
### exnt
```json
[ "errors", "exnt" ]
```
type `exnt` = `variant { ... }`
A variant type
#### Constructors
 Name   | Type   | Description                            
--------|--------|----------------------------------------
 errors | string | Errors raised during an RPC invocation 
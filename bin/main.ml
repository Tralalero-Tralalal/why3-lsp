open Why3
open Itp_communication

(*******************)
(* server protocol *)
(*******************)

module Protocol_lsp = struct 
  let debug_proto =
    Debug.register_flag "lsp_proto"
      ~desc:"Print@ debugging@ messages@ about@ Why3lsp@ protocol@"

  let print_request_debug r =
    Debug.dprintf debug_proto "[request]";
    Debug.dprintf debug_proto "%a" print_request r

  let print_notify_debug n =
    Debug.dprintf debug_proto "[notification]";
    Debug.dprintf debug_proto "%a@." print_notify n

  let list_requests : ide_request list ref = ref []

  let get_requests () =
    let n = List.length !list_requests in
    if n > 0 then Debug.dprintf debug_proto "got %d new requests@." n;
    let l = List.rev !list_requests in
    list_requests := [];
    l

  let send_request r =
    print_request_debug r;
    list_requests := r :: !list_requests

  let notification_list : notification list ref = ref []

  let notify n =
    (* too early, print when handling notifications print_notify_debug n; *)
    notification_list := n :: !notification_list

  let get_notified () =
    let n = List.length !notification_list in
    if n > 0 then Debug.dprintf debug_proto "got %d new notifications@." n;
    let l = List.rev !notification_list in
    notification_list := [];
    l
end

let get_notified = Protocol_lsp.get_notified

let send_request = Protocol_lsp.send_request

module Server = Itp_server.Make (Unix_scheduler) (Protocol_lsp)


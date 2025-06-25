
module Sched = struct

    (* TODO temporary. This scheduler should be split *)
    let blocking = false

    let multiplier = 3

    (* the private list of functions to call on idle, sorted higher
       priority first. *)
    let idle_handler : (int * (unit -> bool)) list ref = ref []

    (* [insert_idle_handler p f] inserts [f] as a new function to call
       on idle, with priority [p] *)
    let insert_idle_handler p f =
      let rec aux l =
        match l with
          | [] -> [p,f]
          | (p1,_) as hd :: rem ->
             if p > p1 then (p,f) :: l else hd :: aux rem
      in
      idle_handler := aux !idle_handler

    (* the private list of functions to call on timeout, sorted on
       earliest trigger time first. *)
    let timeout_handler : (float * float * (unit -> bool)) list ref = ref []

    (* [insert_timeout_handler ms t f] inserts [f] as a new function to call
       on timeout, with time step of [ms] and first call time as [t] *)
    let insert_timeout_handler ms t f =
      let rec aux l =
        match l with
          | [] -> [ms,t,f]
          | (_,t1,_) as hd :: rem ->
             if t < t1 then (ms,t,f) :: l else hd :: aux rem
      in
      timeout_handler := aux !timeout_handler

    (* public function to register a task to run on idle *)
    let idle ~(prio:int) f = insert_idle_handler prio f

    (* public function to register a task to run on timeout *)
    let timeout ~ms f =
      assert (ms > 0);
      let ms = float ms /. 1000.0 in
      let time = Unix.gettimeofday () in
      insert_timeout_handler ms (time +. ms) f

end

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


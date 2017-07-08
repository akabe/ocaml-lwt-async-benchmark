open Core
open Async
open Core.Caml.Format

let benchmark n_loops n_threads =
  let rec loop i =
    if i = n_loops then return ()
    else return (i + 1) >>= loop
  in
  let t0 = Unix.gettimeofday () in
  List.init n_threads ~f:(fun _ -> loop 0)
  |> Deferred.all >>| fun _ ->
  let t1 = Unix.gettimeofday () in
  (t1 -. t0)

let main =
  let n_loops = 1000000 in
  printf "# threads time@." ;
  List.init 10 ~f:succ
  |> List.fold_left
    ~init:Deferred.unit
    ~f:(fun acc n_threads ->
        acc >>= fun () ->
        benchmark n_loops n_threads >>| fun t ->
        printf "%d %g@." n_threads t)
  >>= fun _ ->
  Shutdown.exit 0

let () =
  don't_wait_for main ;
  never_returns (Scheduler.go ())

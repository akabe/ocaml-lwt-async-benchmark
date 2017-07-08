open Core
open Core.Caml.Format
open Lwt.Infix

let benchmark n_loops n_threads =
  let rec loop i =
    if i = n_loops then Lwt.return ()
    else Lwt.return (i + 1) >>= loop
  in
  let t0 = Unix.gettimeofday () in
  List.init n_threads ~f:(fun _ -> loop 0)
  |> Lwt_list.map_p Lwt.return >|= fun _ ->
  let t1 = Unix.gettimeofday () in
  (t1 -. t0)

let main =
  let n_loops = 1000000 in
  printf "# threads time@." ;
  List.init 10 ~f:succ
  |> Lwt_list.iter_s
    (fun n_threads ->
       benchmark n_loops n_threads >|= fun t ->
       printf "%d %g@." n_threads t)

let () = Lwt_main.run main

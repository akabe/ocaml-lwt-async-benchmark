open Core
open Core.Caml.Format
open Lwt.Infix

let rec reader r =
  Lwt_stream.get r >>= function
  | None -> Lwt.return ()
  | Some _ -> reader r

let writer ~n_loops ~data =
  let i = ref 0 in
  fun () ->
    if !i = n_loops then Lwt.return_none else begin
      incr i ;
      Lwt.return_some data
    end

let reader_writer ~n_loops =
  let data = (String.make 100 'a') in
  let r = Lwt_stream.from (writer ~n_loops ~data) in
  reader r

let benchmark n_loops n_threads =
  let t0 = Unix.gettimeofday () in
  List.init n_threads ~f:(fun _ -> reader_writer ~n_loops)
  |> Lwt_list.map_p Lwt.return >|= fun _ ->
  let t1 = Unix.gettimeofday () in
  (t1 -. t0)

let main =
  let n_loops = 1000 in
  printf "# threads time@." ;
  List.init 10 ~f:(fun i -> (i + 1) * 100)
  |> Lwt_list.iter_s
    (fun n_threads ->
       benchmark n_loops n_threads >|= fun t ->
       printf "%d %g@." n_threads t)

let () = Lwt_main.run main

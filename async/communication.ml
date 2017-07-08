open Core
open Async
open Core.Caml.Format

let rec reader r =
  Pipe.read r >>= function
  | `Eof -> return ()
  | `Ok _ -> reader r

let writer ~n_loops ~data w =
  let rec aux i =
    if i = n_loops then begin
      Pipe.close w ;
      return ()
    end else begin
      Pipe.write w data >>= fun () ->
      aux (i + 1)
    end
  in
  aux 0

let reader_writer ~n_loops =
  let r, w = Pipe.create () in
  let data = (String.make 100 'a') in
  Deferred.both (reader r) (writer ~n_loops ~data w) >>| ignore

let benchmark n_loops n_threads =
  let t0 = Unix.gettimeofday () in
  List.init n_threads ~f:(fun _ -> reader_writer ~n_loops)
  |> Deferred.all >>| fun _ ->
  let t1 = Unix.gettimeofday () in
  (t1 -. t0)

let main =
  let n_loops = 1000 in
  printf "# threads time@." ;
  List.init 10 ~f:(fun i -> (i + 1) * 100)
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

open Core
open Core.Caml.Format

let benchmark n_loops n_threads =
  let rec loop i = if i < n_loops then loop (i + 1) in
  let t0 = Unix.gettimeofday () in
  let _ = List.init n_threads ~f:(fun _ -> loop 0) in
  let t1 = Unix.gettimeofday () in
  (t1 -. t0)

let main =
  let n_loops = 1000000 in
  printf "# threads time@." ;
  List.init 10 ~f:succ
  |> List.iter
    ~f:(fun n_threads ->
        let t = benchmark n_loops n_threads in
        printf "%d %g@." n_threads t)

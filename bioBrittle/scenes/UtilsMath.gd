extends Node


func sum(arr):
	var sum = 0;
	for x in arr:
		sum += x;
	return(sum);


func angle_to_vector(angle):
	return(Vector2(cos(angle),sin(angle)));


func is_intersection_polygons(poly1, poly2):
	return(Geometry.intersect_polygons_2d(poly1, poly2).size()>0);


func get_lowest_point(arr):
	var lowest = null;
	for point in arr:
		if lowest==null or point.y > lowest.y:
			lowest = point;
	return(lowest);


func get_highest_point(arr):
	var highest = null;
	for point in arr:
		if highest==null or point.y < highest.y:
			highest = point;
	return(highest);


func get_intermediate_points(start, end, n_points):
	var step = (end-start)/(n_points+1);
	var arr = [];
	for i in range(n_points):
		arr.append(start + (i+1)*step);
	return(arr);


func sample_one(arr_in):
	return(sample(arr_in, 1, true)[0]);


func sample_without_replacement(arr_in : Array, k) -> Array:
	return(sample(arr_in, k, false));


func sample_with_replacement(arr_in : Array, k):
	return(sample(arr_in, k, true));


func sample(arr_in : Array, k, replace):
	if arr_in.size()==0:
		return(null);
	var arr = arr_in.duplicate();
	var arr_sample = [];
	for i in range(k):
		if arr.size()==0:
			break;
		var ix = randi() % arr.size();
		arr_sample.append(arr[ix]);
		if not replace:
			arr.remove(ix);
	return(arr_sample);


func get_rand_alloc_arr(n):
	var arr = [];
	var sum = 0;
	for i in range(n):
		var frac = rand_range(0.5,1);
		arr.append(frac);
		sum += frac;
	for i in range(n):
		arr[i] /= sum;
	return(arr);


func shuffle(arr):
	for i in range(arr.size()-1):
		var ix = randi() % (arr.size()-i) + i;
		var temp = arr[i];
		arr[i] = arr[ix];
		arr[ix] = temp;


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



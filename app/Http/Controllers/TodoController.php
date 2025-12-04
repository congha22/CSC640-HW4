<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Item;

class TodoController extends Controller
{
    // GET /api/todos
    public function index(Request $request)
    {
        $items = $request->user()->items()->orderByDesc('id')->get(['id','title','completed','created_at']);
        return response()->json(['items' => $items]);
    }

    // POST /api/todos
    public function store(Request $request)
    {
        $data = $request->validate(['title' => 'required|string']);
        $item = $request->user()->items()->create(['title' => $data['title']]);
        return response()->json(['ok' => true, 'id' => $item->id]);
    }

    // PUT /api/todo?id=...
    public function update(Request $request)
    {
        $id = intval($request->query('id', 0));
        if ($id <= 0) return response()->json(['error'=>'id_required'], 400);

        $item = $request->user()->items()->where('id', $id)->first();
        if (!$item) return response()->json(['error' => 'not_found'], 404);

        $data = $request->only(['title','completed']);
        if (isset($data['title'])) $item->title = $data['title'];
        if (isset($data['completed'])) $item->completed = boolval($data['completed']);
        $item->save();

        return response()->json(['ok' => true, 'updated' => 1]);
    }

    // DELETE /api/todo?id=...
    public function destroy(Request $request)
    {
        $id = intval($request->query('id', 0));
        if ($id <= 0) return response()->json(['error'=>'id_required'], 400);
        $deleted = $request->user()->items()->where('id', $id)->delete();
        return response()->json(['ok' => true, 'deleted' => $deleted]);
    }
}

<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Task;
use App\Models\User;
use Illuminate\Support\Facades\Auth;

class TaskController extends Controller
{
    public function index()
    {
        return Auth::user()->tasks;
    }
    public function store(Request $request)
    {
        $request->validate([
            'title' => 'required|string',
            'priority' => 'required|in:low,medium,high',
            'due_date' => 'required|date',
        ]);
        $task = Auth::user()->tasks()->create([
            'title' => $request->title,
            'priority' => $request->priority,
            'due_date' => $request->due_date,
            'is_done' => 'false'
        ]);
        return response()->json($task, 201);
    }
    public function update(Request $request, $id)
    {
        $task = Auth::user()->tasks()->findOrFail($id);
        $task->update($request->only(['title', 'priority', 'due_date', 'is_done']));
        return response()->json($task);
    }
    public function destroy($id)
    {
        $task = Auth::user()->tasks()->findOrFail($id);
        $task->delete();
        return response()->json(null, 204);
    }
}

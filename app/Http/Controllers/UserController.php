<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;

class UserController extends Controller
{
    public function me(Request $request)
    {
        $user = $request->user();
        return response()->json(['user' => [
            'id' => $user->id,
            'username' => $user->username,
            'created_at' => $user->created_at,
        ]]);
    }
}

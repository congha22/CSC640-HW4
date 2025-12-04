<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    // Register (username, password)
    public function register(Request $request)
    {
        $data = $request->validate([
            'username' => 'required|string|unique:users,username',
            'password' => 'required|string|min:3',
        ]);

        $user = User::create([
            'username' => $data['username'],
            'password' => Hash::make($data['password']),
            'name' => $data['username'],
            'email' => $data['username'].'@example.local',
        ]);

        return response()->json(['ok' => true, 'user_id' => $user->id]);
    }

    // Login - return Sanctum personal access token
    public function login(Request $request)
    {
        $data = $request->validate([
            'username' => 'required|string',
            'password' => 'required|string',
        ]);

        $user = User::where('username', $data['username'])->first();
        if (! $user || ! Hash::check($data['password'], $user->password)) {
            return response()->json(['error' => 'invalid_credentials'], 401);
        }

        $token = $user->createToken('api-token')->plainTextToken;
        return response()->json(['ok' => true, 'token' => $token]);
    }

    // Logout - revoke token supplied in Authorization header
    public function logout(Request $request)
    {
        // Remove current token
        $request->user()->currentAccessToken()->delete();
        return response()->json(['ok' => true]);
    }
}

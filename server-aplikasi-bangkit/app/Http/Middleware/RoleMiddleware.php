<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class RoleMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @param  string  ...$roles
     * @return mixed
     */
    public function handle(Request $request, Closure $next, ...$roles)
    {
        // Set the guard to 'api' explicitly
        auth()->shouldUse('api');

        // Get the authenticated user
        $user = auth()->user();

        // Check if user exists and has the required role
        if (!$user || !in_array($user->peran, $roles)) {
            return response()->json([
                'status' => 'error',
                'message' => 'Unauthorized access',
                'required_roles' => $roles,
                'your_role' => $user ? $user->peran : 'guest'
            ], Response::HTTP_FORBIDDEN);
        }

        return $next($request);
    }
}

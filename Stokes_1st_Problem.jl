### A Pluto.jl notebook ###
# v0.12.3

using Markdown
using InteractiveUtils

# ╔═╡ ac3cc660-08e1-11eb-3db6-0d5949a89423
begin
	using Plots
	using Printf
end

# ╔═╡ ed659260-08e2-11eb-2951-2be739c080ed
md"_MAE 5943 Homework 2, version 1_"

# ╔═╡ 59909ca0-08e3-11eb-3348-41080f6a2bd8
md"""

## **Homework 2** - _Stokes 1ˢᵗ Problem_
`MAE 5943`, `Fall 2020`

#### **Description:**

This notebook computes the Stokes 1ˢᵗ Problem (flow over a suddenly moved infinetely long flat plate from rest.)

		stokes1st(ηmax, N, itermax, ϵProfile, ϵBC)

If the arguments are missing, it will use the default values.
    
		stokes1st(ηmax=10, N=30, itermax=40, ϵProfile=1e-6, ϵBC=1e-6)


#### **Stokes 1ˢᵗ Problem (Rayleigh Problem)**
Consider a stagnant infinitely long plate which moved suddenly at constant speed.
The flow can be represented using the ordinary differential equation (ODE) below:

$$f'' + η f' = 0$$

Boundary Conditions:

$$f(0) = 1$$
$$f(η→∞) → 0$$

Please see the lecture notes for [more information](https://teams.microsoft.com/l/file/4D475CBE-B3BC-47A7-9EC9-A6B7CECDDB6B?tenantId=2a69c91d-e849-4e34-a230-cdf8b27e1964&fileType=pdf&objectUrl=https%3A%2F%2Fostatemailokstate.sharepoint.com%2Fsites%2FSTW_MAE_5943_UNSTEADY_AERODYNAMICS%2FShared%20Documents%2FWeek%2001%20-%20Introduction%2F05_MAE_5943_Stokes_Problem.pdf&baseUrl=https%3A%2F%2Fostatemailokstate.sharepoint.com%2Fsites%2FSTW_MAE_5943_UNSTEADY_AERODYNAMICS&serviceName=teams&threadId=19:bcec5825f6c440bfada9e3f6b9ea8555@thread.tacv2&messageId=1599926278210&groupId=ca352ade-ad9b-455f-a3a9-0c53f6111fc3) on the derivation of the ODE and numerical solution method.

#### **Solution Method:**

The equations given above are solved using Thomas algorithm. (Add details here!)

Feel free to ask questions!

*MAE 5943 - Unsteady Aerodynamics, Fall 2020* 

*Dr. Kursat Kara*

[kursat.kara@okstate.edu](kursat.kara@okstate.edu)

"""

# ╔═╡ d47c93d0-08e1-11eb-0e92-21ca5523e6c6
"""
Computes the Stokes 1st Problem (Rayleigh Problem)

    stokes1st(ηmax, N, itermax, ϵProfile, ϵBC)

If the arguments are missing, it will use the default values.
    
    stokes1st(ηmax=10, N=30, itermax=40, ϵProfile=1e-6, ϵBC=1e-6)

MAE 5943 - Unsteady Aerodynamics,
Dr. Kursat Kara,
[kursat.kara@okstate.edu](kursat.kara@okstate.edu),
Fall 2020. 
    
"""
function stokes1st(ηmax=10, N=30, itermax=40, ϵProfile=1e-6, ϵBC=1e-6)
 
	Δη = ηmax/N
    Δη²= Δη^2;

    #itermax = 40
    #ϵProfile = 1e-6
    #ϵBC = 1e-6

    iter = 0
    errorProfile = 1.
    errorBC = 1.;

    # Initialization of the arrays
    A = zeros(N+1)
    B = zeros(N+1)
    C = zeros(N+1)
    D = zeros(N+1)

    G = zeros(N+1)
    H = zeros(N+1)

#    p = zeros(N+1)
    h = zeros(N+1)
    η = zeros(N+1)

    η = [(i-1)*Δη for i=1:N+1];

    #BCs
    h[1]   = 1.0   # h(η=0) = 1
    h[N+1] = 0.0   # h(η=∞) = 0
#    p[1]   = 0.0   # p(η=0) = 0

    G[1] = 1.0
    H[1] = 0.0;

    #Solution initialization

    #= assume a linear profile for h(η)
    h = [(i-1)/N  for i=1:N+1]

    for i = 2:N+1
        p[i] = p[i-1] + (h[i] + h[i-1])*Δη/2
    end
	=#
	
    println("iter     error            convergence of h(η→∞)")
    println("-----------------------------------------------")

    #while ϵProfile<=errorProfile && ϵBC<=errorBC && iter<itermax
    while ϵProfile<=errorProfile && iter<itermax
  
	#= Hiemenz Flow		
		A = [ 1/Δη² + p[i]/(2*Δη) for i=1:N+1]
        B = [-2/Δη² - h[i] for i=1:N+1]
        C = [ 1/Δη² - p[i]/(2*Δη) for i=1:N+1]
        D = [1 for i=1:N+1]
	=#
		
	#= Homann Flow		
		A = [ 1/Δη² + p[i]/Δη for i=1:N+1]
		B = [-2/Δη² - h[i] for i=1:N+1]
		C = [ 1/Δη² - p[i]/Δη for i=1:N+1]
		D = [1 for i=1:N+1]
	=#
		
	# Stokes 1st Problem		
		A = [ 1/Δη² + η[i]/(2*Δη) for i=1:N+1]
		B = [-2/Δη² for i=1:N+1]
		C = [ 1/Δη² - η[i]/(2*Δη) for i=1:N+1]
		D = [0 for i=1:N+1]
	#
		
        for i=2:N
            G[i] = - ( C[i]*G[i-1] + D[i] )/(B[i] + C[i] * H[i-1])
            H[i] = -                 A[i]  /(B[i] + C[i] * H[i-1])
        end

        hold = copy(h)

        for i=N:-1:2
            h[i] = G[i] + H[i] * h[i+1]
        end 

        errorProfile = maximum(abs.(hold-h))

        errorBC = abs(h[N+1]-h[N])

        #=
		for i = 2:N
            p[i] = p[i-1] + (h[i] + h[i-1])*Δη/2
        end
		=#
		
        iter += 1

        #println("iter: $iter,  errorProfile: $errorProfile, errorBC: $errorBC")
        @printf("%4.4d %16.6e %16.6e \n", iter, errorProfile, errorBC)
    end

     if errorProfile<=ϵProfile 
        println("")
        println("Solution converged!")
        println("The maximum change between consecutive profiles is less than the error criteria ϵProfile=$ϵProfile.")
     end

     if errorBC<=ϵBC
        println("")
        println("Solution for the boundary condition converged!")
        println("The difference between h(N) and h(N+1) is less than the error criteria ϵBC=$ϵBC.")
     end
    return η,h
end

# ╔═╡ df424c60-08e1-11eb-319f-2fa7a0f0fb08
stokes1st();

# ╔═╡ 07798e4e-08e2-11eb-3066-0120057d15b2
ηtest, htest = stokes1st(10,30);

# ╔═╡ f0a39bd0-08e1-11eb-3d16-ffb6b9e631e0
plot(htest,ηtest,
        title = "Stokes 1st Problem",
        label = "ϕ'",
        legend = :topleft,
        xlabel = "h = ϕ'",
        ylabel = "η",
        linewidth = 2,
        linecolor = :black,
        markershape = :circle,
        markercolor = :red,
	)

# ╔═╡ 638b8090-08e2-11eb-2c26-7b7f6caa7d14
md"""
#### The effect of ηmax:
N is selected as 30 and the error limit is 1e-6.
"""

# ╔═╡ 7bbba7b0-08e9-11eb-3d8c-75a72baa41fe
begin
	η5, h5 = stokes1st(5);
	η10, h10 = stokes1st(10);
	η20, h20 = stokes1st(20);
end
	

# ╔═╡ d8a1b2d0-08e9-11eb-1c9a-91c4d297b41e
plot([h5, h10, h20], [η5, η10, η20],
        title = "Stokes 1st Problem - Effect of ηmax",
        label = ["ηmax = 5" "ηmax = 10" "ηmax = 20"],
        legend = :topleft,
        xlabel = "h",
        ylabel = "η",
        linewidth = 1,
        linecolor = :black,
        markershape = [:x :utriangle :dtriangle],
        markersize = [5 5 5],
        markeralpha = [0.9 0.6 0.6],
        markercolor = [:black :red :green]
    ,)

# ╔═╡ 2a95ec50-08ea-11eb-06a4-050c654d9c1f
md"""
#### The effect of N:
ηmax is selected as 10 and the error limit is 1e-6.
"""

# ╔═╡ 3649fc80-08ea-11eb-28b5-f58a62c010da
begin
	ηN10, hN10 = stokes1st(10, 10);
	ηN20, hN20 = stokes1st(10, 20);
	ηN40, hN40 = stokes1st(10, 40);
	ηN80, hN80 = stokes1st(10, 80);
end

# ╔═╡ 5241b720-08ea-11eb-3fad-5f8164fe40f6
begin
	gr()
plot([hN10, hN20, hN40, hN80], [ηN10, ηN20, ηN40, ηN80],
        seriestype = :scatter,    
        title = "Stokes 1st Problem - Effect of Grid Resolution",
        label = ["N = 10" "N = 20" "N = 40" "N = 80"],
        legend = :topleft,
        xlabel = "h",
        ylabel = "η",
        markershape = [:circle :utriangle :dtriangle :square],
        markersize = [10 8 6 3],
        markeralpha = [0.6 0.6 0.6 0.6],
        markercolor = [:purple :red :green :blue]
    ,)
end

# ╔═╡ Cell order:
# ╟─ed659260-08e2-11eb-2951-2be739c080ed
# ╟─59909ca0-08e3-11eb-3348-41080f6a2bd8
# ╟─ac3cc660-08e1-11eb-3db6-0d5949a89423
# ╟─d47c93d0-08e1-11eb-0e92-21ca5523e6c6
# ╠═df424c60-08e1-11eb-319f-2fa7a0f0fb08
# ╠═07798e4e-08e2-11eb-3066-0120057d15b2
# ╟─f0a39bd0-08e1-11eb-3d16-ffb6b9e631e0
# ╟─638b8090-08e2-11eb-2c26-7b7f6caa7d14
# ╠═7bbba7b0-08e9-11eb-3d8c-75a72baa41fe
# ╟─d8a1b2d0-08e9-11eb-1c9a-91c4d297b41e
# ╟─2a95ec50-08ea-11eb-06a4-050c654d9c1f
# ╠═3649fc80-08ea-11eb-28b5-f58a62c010da
# ╟─5241b720-08ea-11eb-3fad-5f8164fe40f6

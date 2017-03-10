# Adapted from:
# SOSDEMO4 --- Matrix Copositivity
# Section 3.4 of SOSTOOLS User's Manual

@testset "SOSDEMO4 with $solver" for solver in sdp_solvers
  @polyvar x[1:5]

  # The matrix under consideration
  J = [1 -1  1  1 -1;
      -1  1 -1  1  1;
       1 -1  1 -1  1;
       1  1 -1  1 -1;
      -1  1  1 -1  1]

  xs = x.^2
  xsJxs = dot(xs, J*xs)
  r = sum(xs)

  m0 = Model(solver = solver)
  @polyconstraint m0 xsJxs >= 0
  status = solve(m0)
  @test status == :Infeasible

  m1 = Model(solver = solver)
  @polyconstraint m1 r*xsJxs >= 0
  status = solve(m1)
  @test status == :Optimal
  # Program is feasible. The matrix J is copositive
end

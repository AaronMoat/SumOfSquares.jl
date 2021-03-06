using Test
using SumOfSquares
import MultivariateBases
const MB = MultivariateBases

function xor_complement_test()
    @test Certificate.xor_complement([1], 1) == Int[]
    @test Certificate.xor_complement(Int[], 1) == [1]
    @test Certificate.xor_complement([1], 2) == [2]
    @test Certificate.xor_complement([2], 2) == [1]
    @test Certificate.xor_complement([1, 2], 2) == Int[]
    @test Certificate.xor_complement([1, 3], 2) == Int[]
    @test Certificate.xor_complement(Int[], 2) == [1, 2]
    @test Certificate.xor_complement([7], 3) == [3, 5]
    @test Certificate.xor_complement([5, 6, 3], 3) == [7]
    @test Certificate.xor_complement([3], 3) == [3, 4]
end

set_monos(bases::Vector{<:MB.MonomialBasis}) = Set([basis.monomials for basis in bases])

function Certificate.sparsity(monos::AbstractVector{<:MP.AbstractMonomial}, domain::SemialgebraicSets.BasicSemialgebraicSet, sp::MonomialSparsity, maxdegree, degs)
    half_monos = Certificate.maxdegree_gram_basis(MB.MonomialBasis, variables, div(maxdegree, 2))
    P = Set(monos)
end

"""
    wml19()

Examples of [MWL19].

[WML19] Wang, Jie, Victor Magron, and Jean-Bernard Lasserre. "TSSOS: A Moment-SOS hierarchy that exploits term sparsity." arXiv preprint arXiv:1912.08899 (2019).
"""
function wml19()
    certificate = Certificate.Newton(SOSCone(), MB.MonomialBasis, tuple())
    @testset "Example 4.2" begin
        @polyvar x[1:3]
        f = 1 + x[1]^4 + x[2]^4 + x[3]^4 + prod(x) + x[2]
        expected_1_false = Set(monovec.([
            [x[3]^2],
            [x[1] * x[3], x[2]],
            [x[2], 1],
            [x[2]^2],
            [x[2] * x[3], x[1]],
            [x[1] * x[2], x[3]],
            [x[1]^2]
        ]))
        expected_1_true = Set(monovec.([
            [x[1]^2, x[2]^2, x[3]^2, 1],
            [x[1] * x[3], x[2]],
            [x[2], 1],
            [x[2] * x[3], x[1]],
            [x[1] * x[2], x[3]]
        ]))
        expected_2 = Set(monovec.([
            [x[1]^2, x[2]^2, x[3]^2, 1],
            [x[2] * x[3], x[1]],
            [x[2], 1],
            [x[1] * x[3], x[2]],
            [x[1] * x[2], x[3]]
        ]))
        @testset "$k $use_all_monomials" for k in 0:2, use_all_monomials in [false, true]
            expected = k == 1 ? (use_all_monomials ? expected_1_true : expected_1_false) : expected_2
            @test set_monos(Certificate.sparsity(f, MonomialSparsity(k, use_all_monomials), certificate)) == expected
        end
        expected = Set(monovec.([
            [x[1]^2, x[1] * x[3], x[2]^2, x[3]^2, x[2], 1],
            [x[1] * x[2], x[2] * x[3], x[1], x[3]]
        ]))
        @test set_monos(Certificate.sparsity(f, SignSymmetry(), certificate)) == expected
    end
    @testset "Example 5.4" begin
        preorder_certificate = Certificate.Putinar(Certificate.MaxDegree(SOSCone(), MB.MonomialBasis, 4), SOSCone(), MB.MonomialBasis, 4)
        @polyvar x[1:2]
        f = x[1]^4 + x[2]^4 + x[1] * x[2]
        K = @set 1 - 2x[1]^2 - x[2]^2 >= 0
        @testset "$k $use_all_monomials" for k in 0:2, use_all_monomials in [false, true]
            basis, preorder_bases = Certificate.sparsity(f, K, MonomialSparsity(k, use_all_monomials), preorder_certificate)
            if k == 1
                if use_all_monomials
                    @test set_monos(preorder_bases[1]) == Set(monovec.([[x[1], x[2]], [constantmonomial(x[1] * x[2])]]))
                    @test set_monos(basis) == Set(monovec.([[x[1], x[2]], [x[1] * x[2], 1], [x[1]^2, x[2]^2, 1]]))
                else
                    @test set_monos(preorder_bases[1]) == Set(monovec.([[x[1], x[2]]]))
                    @test set_monos(basis) == Set(monovec.([[x[1]^2], [x[1]*x[2], 1], [x[2]^2], [x[1], x[2]]]))
                end
            else
                @test set_monos(basis) == Set(monovec.([[x[1]^2, x[1]*x[2], x[2]^2, 1], [x[1], x[2]]]))
                @test set_monos(preorder_bases[1]) == Set(monovec.([[constantmonomial(x[1] * x[2])], [x[1], x[2]]]))
            end
        end
    end
    @testset "Example 6.7" begin
        @polyvar x[1:2]
        f = 1 + x[1]^2 * x[2]^4 + x[1]^4 * x[2]^2 + x[1]^4 * x[2]^4 - x[1] * x[2]^2 - 3x[1]^2 * x[2]^2
        @testset "$k" for k in 0:2, use_all_monomials in [false, true]
            @test set_monos(Certificate.sparsity(f, MonomialSparsity(k, use_all_monomials), certificate)) == Set(monovec.([
                [x[1] * x[2]^2, 1], [x[1]^2 * x[2]^2, 1], [x[1] * x[2]], [x[1]^2 * x[2]]
            ]))
        end
        @test set_monos(Certificate.sparsity(f, SignSymmetry(), certificate)) == Set(monovec.([
            [x[1]^2 * x[2]^2, x[1] * x[2]^2, 1], [x[1]^2 * x[2], x[1] * x[2]]
        ]))
    end
end
"""
    l09()

Examples of [MWL19].

[L09] Lofberg, Johan. "Pre-and post-processing sum-of-squares programs in practice." IEEE transactions on automatic control 54.5 (2009): 1007-1011.
"""
function l09()
    certificate = Certificate.Newton(SOSCone(), MB.MonomialBasis, tuple())
    @testset "Example 1 and 2" begin
        @polyvar x[1:2]
        f = 1 + x[1]^4 * x[2]^2 + x[1]^2 * x[2]^4
        @test Certificate.monomials_half_newton_polytope(monomials(f), tuple()) == [
            x[1]^2 * x[2], x[1] * x[2]^2, 1
        ]
        expected = Set(monovec.([
            [x[1]^2 * x[2]], [x[1] * x[2]^2], [constantmonomial(x[1] * x[2])]
        ]))
        for i in 0:2
            @test set_monos(Certificate.sparsity(f, MonomialSparsity(i), certificate)) == expected
        end
        @test set_monos(Certificate.sparsity(f, SignSymmetry(), certificate)) == expected
    end
    @testset "Example 3 and 4" begin
        @polyvar x[1:3]
        f = 1 + x[1]^4 + x[1] * x[2] + x[2]^4 + x[3]^2
        @testset "$k $use_all_monomials" for k in 0:2, use_all_monomials in [false, true]
            if k == 1
                if use_all_monomials
                    @test set_monos(Certificate.sparsity(f, MonomialSparsity(k, use_all_monomials), certificate)) == Set(monovec.([
                        [x[1]^2, x[2]^2, 1], [x[1], x[2]], [x[1] * x[2], 1], [x[3]]
                    ]))
                else
                    @test set_monos(Certificate.sparsity(f, MonomialSparsity(k, use_all_monomials), certificate)) == Set(monovec.([
                        [x[1]^2], [x[2]^2], [x[1], x[2]], [x[1] * x[2], 1], [x[3]]
                    ]))
                end
            else
                @test set_monos(Certificate.sparsity(f, MonomialSparsity(k, use_all_monomials), certificate)) == Set(monovec.([
                    [x[1], x[2]], [x[3]], [x[1]^2, x[2]^2, 1], [x[1] * x[2], 1]
                ]))
            end
        end
        @test set_monos(Certificate.sparsity(f, SignSymmetry(), certificate)) == Set(monovec.([
            [x[1], x[2]], [x[3]], [x[1]^2, x[1] * x[2], x[2]^2, 1]
        ]))
    end
end
function square_domain()
    d = 6
    preorder_certificate = Certificate.Putinar(Certificate.MaxDegree(SOSCone(), MB.MonomialBasis, 6), SOSCone(), MB.MonomialBasis, 6)
    @polyvar x y
    f = x^2*y^4 + x^4*y^2 - 3*x^2*y*2 + 1
    K = @set(1 - x^2 >= 0 && 1 - y^2 >= 0)
    @testset "Square domain $k $use_all_monomials" for k in 0:4, use_all_monomials in [false, true]
        basis, preorder_bases = Certificate.sparsity(f, K, MonomialSparsity(k, use_all_monomials), preorder_certificate)
        if k == 1
            if use_all_monomials
                @test set_monos(basis) == Set(monovec.([[x^2 * y, y, 1], [x^3, x * y^2, x], [x^2, y, 1], [x^2, y^2, 1], [x^2 * y, y^3, y], [x * y, x]]))
            else
                @test set_monos(basis) == Set(monovec.([[x^2 * y, y^3], [x^2, y], [x^2 * y, 1], [x^3, x * y^2], [x * y, x]]))
            end
        elseif k == 2
            @test set_monos(basis) == Set(monovec.([[x^2 * y, x^2, y^2, 1], [x^3, x * y^2, x * y, x], [x^2 * y, x^2, y, 1], [x^2 * y, y^3, x^2, y]]))
        elseif k == 3
            @test set_monos(basis) == Set(monovec.([[x^3, x * y^2, x * y, x], [x^2 * y, x^2, y^2, y, 1], [x^2 * y, y^3, x^2, y, 1]]))
        else
            @test set_monos(basis) == Set(monovec.([[x^3, x * y^2, x * y, x], [x^2 * y, y^3, x^2, y^2, y, 1]]))
        end
        expected = Set(monovec.([[x^2, y^2, y, 1], [x * y, x]]))
        if k == 1
            if use_all_monomials
                @test set_monos(preorder_bases[1]) == Set(monovec.([[x * y, x], [x^2, y, 1], [x^2, y^2, 1]]))
            else
                @test set_monos(preorder_bases[1]) == Set(monovec.([[y, 1], [x * y, x], [x^2, y], [x^2, y^2]]))
            end
        else
            @test set_monos(preorder_bases[1]) == expected
        end
        if k == 1
            if use_all_monomials
                @test set_monos(preorder_bases[2]) == Set(monovec.([[x * y, x], [x^2, y], [x^2, y^2, 1]]))
            else
                @test set_monos(preorder_bases[2]) == Set(monovec.([[x * y, x], [x^2, y], [x^2, y^2], [constantmonomial(x * y)]]))
            end
        elseif k == 2
            @test set_monos(preorder_bases[2]) == Set(monovec.([[x^2, y^2, 1], [x^2, y, 1], [x * y, x]]))
        else
            @test set_monos(preorder_bases[2]) == expected
        end
    end

end
function sum_square(n)
    @testset "Sum square" begin
        @polyvar x[1:(2n)]
        certificate = Certificate.Newton(SOSCone(), MB.MonomialBasis, tuple())
        f = sum((x[1:2:(2n-1)] .- x[2:2:(2n)]).^2)
        expected = Set(monovec.([monovec([x[(2i - 1)], x[2i], 1]) for i in 1:n]))
        @test set_monos(Certificate.sparsity(f, VariableSparsity(), Certificate.MaxDegree(SOSCone(), MB.MonomialBasis, 2))) == expected
        expected = Set(monovec.([[x[(2i - 1)], x[2i]] for i in 1:n]))
        @test set_monos(Certificate.sparsity(f, SignSymmetry(), certificate)) == expected
    end
end
function drop_monomials()
    @testset "Drop monomials" begin
        @polyvar x
        f = polynomial(x^2)
        certificate = Certificate.MaxDegree(SOSCone(), MB.MonomialBasis, 2)
        @testset "$k $use_all_monomials" for k in 0:2, use_all_monomials in [false, true]
            # The monomial `1˘ is dropped as it is useless.
            if use_all_monomials
                expected = Set(monovec.([[x], [constantmonomial(x^2)]]))
            else
                expected = Set([monovec([x])])
            end
            @test set_monos(Certificate.sparsity(f, MonomialSparsity(k, use_all_monomials), certificate)) == expected
        end
        preorder_certificate = Certificate.Putinar(Certificate.MaxDegree(SOSCone(), MB.MonomialBasis, 4), SOSCone(), MB.MonomialBasis, 3)
        f = polynomial(x^3)
        K = @set x >= 0
        @testset "$k $use_all_monomials" for k in 0:3, use_all_monomials in [false, true]
            basis, preorder_bases = Certificate.sparsity(f, K, MonomialSparsity(k), preorder_certificate)
            if k == 1
                @test set_monos(basis) == Set(monovec.([[x^2, x]]))
            elseif k == 2
                @test set_monos(basis) == Set(monovec.([[x^2, 1], [x^2, x]]))
            else
                @test set_monos(basis) == Set(monovec.([[x^2, x, 1]]))
            end
            if k == 1
                @test set_monos(preorder_bases[1]) == Set(monovec.([[x]]))
            else
                @test set_monos(preorder_bases[1]) == Set(monovec.([[x, 1]]))
            end
        end
    end
end
@testset "Sparsity" begin
    xor_complement_test()
    wml19()
    l09()
    square_domain()
    sum_square(8)
    @test Certificate.appropriate_type(32) == Int64
    sum_square(32)
    @test Certificate.appropriate_type(64) == Int128
    sum_square(64)
    @test Certificate.appropriate_type(128) == BigInt
    sum_square(128)
    drop_monomials()
end

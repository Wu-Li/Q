###Computer Algebra System###
{
    quad <- function(A,B,C){
        A <- as.complex(A)
        B <- as.complex(B)
        C <- as.complex(C)
        x_1 = (-B + sqrt(4*A*C)) / (2*A)
        x_2 = (-B - sqrt(4*A*C)) / (2*A)
        if(Im(x_1) == 0) { x_1 <- Re(x_1) }
        if(Im(x_2) == 0) { x_2 <- Re(x_2) }
        c(x_1,x_2)
    }
    solve <- function(n,...) {
        v <- c(...)
        print(v)
        m <- matrix(v,ncol=n)
        m <- t(m)
        rref(m)
    }
}

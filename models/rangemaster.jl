# 2017 Ben Holmes
# MIT license

using ACME

# Model of the Dallas Rangemaster Treble Booster guitar peda;

function rangemaster(::Type{Circuit}; vol=nothing)

    # components
    rIn = resistor( 1e3 )
    r1  = resistor( 470e3 )
    r2  = resistor( 68e3 )
    r3  = resistor( 3.9e3 )
    rL  = resistor( 1e6 )
    rB  = resistor( 20 )
    rE  = resistor( 1.21 )
    rC  = resistor( 0.65 )

    if vol == nothing
        p1 = potentiometer( 10e3 )
    else
        p1 = potentiometer( 10e3, vol )
    end

    c1  = capacitor( 4.7e-9 )
    c2  = capacitor( 47e-6 )
    c3  = capacitor( 10e-9 )
    cCB = capacitor( 10e-12 )
    cEB = capacitor( 410e-12 )

    q1  = bjt( :pnp, is=2.12e-6, βf=132.6, βr=15.9 )

    j1 = voltagesource()     # input
    j2 = voltageprobe()      # output
    j3 = voltagesource( 9 )  # supply

    # Connect circuit
    circ = Circuit()

    connect!( circ, j1[:+], rIn[1] )                    # n1
    connect!( circ, rIn[2], c1[1] )                     # n2
    connect!( circ, c1[2], r1[2], r2[1], rB[1] )        # n3
    connect!( circ, j3[:-], r1[1], p1[1] )              # n4
    connect!( circ, rB[2], cCB[1], cEB[1], q1[:base] )  # n5
    connect!( circ, p1[2], c3[1] )                      # n6
    connect!( circ, p1[3], rC[1] )                      # n7
    connect!( circ, rC[2], cCB[2], q1[:collector] )     # n8
    connect!( circ, rE[1], cEB[2], q1[:emitter] )       # n9
    connect!( circ, r3[1], rE[2], c2[1] )               # n10
    connect!( circ, c3[2], rL[1], j2[:+] )              # n11

    connect!(circ, j1[:-], j2[:-], j3[:+], r2[2], r3[2], c2[2], rL[2], :gnd)

    return circ
end

rangemaster{T<:DiscreteModel}(::Type{T}=DiscreteModel; vol=0.99, fs=44100) =
    T(rangemaster(Circuit, vol=vol), 1//fs)

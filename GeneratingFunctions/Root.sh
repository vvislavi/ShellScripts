function RootCorrelation() {
    aliroot -l -b Steer.C+\(\"${1}\"\)
}
function RootCorrelationPP() {
    aliroot -l -b SteerPP.C+\(\"${1}\"\)
}
function TestArg() {
    aliroot -l -b MultiArgs.C\(\"${1}\"\)
}
function CheckFMD() {
    aliroot -l -b CheckFMD.C\(\"${1}\"\)
}
